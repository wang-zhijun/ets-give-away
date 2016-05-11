# EtsGive

## 概要

`https://github.com/DeadZen/etsgive` このレポジトリのElixirバージョン
Mrgプロセスは起動された後に`ETS`テーブルを作成して、自分が`heir`だと設定した後に、すぐowner権限をSrvプロセスに`give_away`, Srvプロセスが死んだらownerは再びMrgに戻る、スーパーバイザーがSrvプロセスを再起動したあと、Mrgが再度ownerをSrvに譲る。


ETSテーブルの`give_away`関数の使い方

```
$ iex -S mix 
> EtsGive.Srv.count
> EtsGive.Srv.count
> EtsGive.Srv.die # Srvプロセスが死ぬ
> EtsGive.Srv.count
```


