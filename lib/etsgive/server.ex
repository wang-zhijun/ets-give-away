defmodule EtsGive.Server do
  use GenServer
  @name __MODULE__

  # EtsGive.Managerから渡してきたETSテーブルのidを保存するため
  defmodule State do
    defstruct table_id: nil
  end

  # ETSテーブルの中身をチェック
  def check() do
    GenServer.cast(@name, :check)
  end

  # ETSテーブルの中身をカウントアップ
  def count() do
    GenServer.cast(@name, :count)
  end

  def die() do
    GenServer.cast(@name, :die)
  end

  # プロセスに名前をつける，これでEtsGive.ManagerもEtsGive.ServerのPidがわかるようになる
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    {:ok, %State{}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(:die, state) do
    # EtsGive.Serverプロセス死ぬと、`:EXIT`メッセージはEtsGive.Managerに送られる
    exit(:killed)
    {:noreply, state}
  end

  def handle_cast(:count, state) do
    table_id = state.table_id
    result = :ets.update_counter(table_id, :count, 1)
    IO.puts "Counter: #{inspect result}"
    {:noreply, state}
  end

  def handle_cast(:check, state) do
    table_id = state.table_id
    IO.puts "table id: #{inspect table_id}, data: #{inspect :ets.tab2list(table_id)}"
    {:noreply, state}
  end
  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info({:'ETS-TRANSFER', table_id, from, _data}, state) do
    IO.puts "manager(#{inspect from}) -> server(#{inspect self()}), getting table id #{inspect table_id}"
    {:noreply, struct(state, table_id: table_id)}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  def terminate(_reason, _state) do
    :ok
  end
end
