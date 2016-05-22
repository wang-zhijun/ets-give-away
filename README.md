# EtsGive

## 概要

`https://github.com/DeadZen/etsgive` このレポジトリのElixirバージョンで,
Managerプロセスは起動された後に`ETS`テーブルを作成して、自分が`heir`だと設定した後に、すぐowner権限をServerプロセスに`give_away`, Serverプロセスが死んだらownerは再びManagerに戻る、スーパーバイザーがServerプロセスを再起動したあと、Managerが再度ownerをSrvに譲る。


ETSテーブルの`give_away`関数の使い方

```
$ iex -S mix 
iex(2)> EtsGive.Server.check
:ok
iex(3)> table id: 245784, data: [count: 0]

nil
iex(8)> EtsGive.Server.count
Counter: 1
:ok
iex(9)> EtsGive.Server.count
:ok
Counter: 2
iex(10)> EtsGive.Server.count
Counter: 3
:ok
iex(11)> EtsGive.Server.die # Serverが死ぬ
:ok
iex(13)> EtsGive.Server.count
Counter: 4
:ok
```


