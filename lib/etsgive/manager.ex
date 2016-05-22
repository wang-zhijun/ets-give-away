defmodule EtsGive.Manager do
  use GenServer
  @name __MODULE__

  defmodule State do
    defstruct table_id: nil
  end

  ###=========================
  ### API
  ###=========================

  def gift() do
    GenServer.cast(@name, {:gift, {:count, 0}})
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    # EtsGive.Serverとlinkしているので，EtsGive.Serverが死ぬときにEtsGive.Managerが死なないように
    Process.flag(:trap_exit, true)
    # EtsGive.ManagerにETSテーブルを作成して，ownerをEtsGive.Serverに変更
    gift()
    {:ok, %State{}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end
  def handle_cast({:gift, data}, state) do
    server = Process.whereis(EtsGive.Server)
    # EtsGive.Managerは自分trap_exitできるので，EtsGive.Serverとlinkして、EtsGive.Serverが死んだらメッセージを受け取る
    Process.link(server) 
    # PublicのETSを使わなくて、嬉しい
    # ETSテーブルをprivateにすると`observer.start`でもETSテーブルの中身がみられない
    table_id = :ets.new(@name, [:private])
    :ets.insert(table_id, data)
    # EtsGive.Managerはこの後すぐtable_idをEtsGive.Serverのほうに譲る.
    # EtsGive.Serverが死ぬと、EtsGive.Managerがこのtable_idの中身を継承すると設定しておく
    :ets.setopts(table_id, {:heir, self(), data})
    # ETSテーブルのオーナー身分をEtsGive.Serverに譲る。
    # これからEtsGive.ServerのほうがこのprivateのETSに対して、操作できるようになる
    :ets.give_away(table_id, server, data)
    {:noreply, struct(state, table_id: table_id)}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  # serverプロセスが死んだらこのメッセージがserverから届く
  def handle_info({:EXIT, _from, :killed}, state) do
    table_id = state.table_id
    IO.puts "Server !! is now dead, farewell table id #{inspect table_id}"
    {:noreply, state}
  end

  # このメッセージは`{:EXIT, _from, :killed}`より先に来る
  def handle_info({:'ETS-TRANSFER', table_id, from, data}, state) do
    server = wait_for_server()
    IO.puts "Warning table id: #{inspect table_id}, Owner Pid: #{inspect from}, server (#{inspect from}) => manager(#{inspect self()}) handing table id #{inspect table_id}"
    # 再度リンクする必要がある
    # managerは自分trap_exitできるから、serverとlinkして、serverが死んだらメッセージを受け取る
    Process.link(server)
    :ets.give_away(table_id, server, data)
    {:noreply, struct(state, table_id: table_id)}
  end

  # EtsGive.MangaerはSupervisorがEtsGive.Serverを再起動完了まで待つ
  def wait_for_server() do
    case Process.whereis(EtsGive.Server) do
      nil ->
        :timer.sleep(1)
        wait_for_server()
      pid -> pid
    end
  end

  def terminate(_reason, _state) do
    :ok
  end
end
