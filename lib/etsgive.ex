defmodule EtsGive do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # 先にServerプロセスを作成
      worker(EtsGive.Server, []),
      # Managerプロセスの中にETSテーブルを作成して，
      # ServerにOwnerを変更
      worker(EtsGive.Manager, [])
    ]

    opts = [strategy: :one_for_one, name: EtsGive.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
