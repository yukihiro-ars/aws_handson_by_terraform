# スケーラブルウェブサイト構築ハンズオンを通してTerraformをかじってみた実行手順

- [スケーラブルウェブサイト構築ハンズオンを通してTerraformをかじってみた実行手順](#スケーラブルウェブサイト構築ハンズオンを通してterraformをかじってみた実行手順)
- [事前準備](#事前準備)
- [実行手順](#実行手順)
- [WordPressにリクエスト](#wordpressにリクエスト)
- [あとかたづけ](#あとかたづけ)


# 事前準備

aws-handson.tfvarsを編集  
DB名、DBユーザ名、パスワード、ヘルスチェックパス、AMIのIDなど…変わる可能性の高い変数をまとめている
~~~
db_name="wordpress"
db_username="admin"
db_password="password"
helthcheck_path="/wp-includes/images/blank.gif"
ami="XXXXXXXXXXXXXXX"
~~~

# 実行手順

ワークスペースの初期化（初回のみ）

~~~
terraform init
~~~

以下「-var-file=aws-handson.tfvars」は変数を外出ししているため指定が必要  

plan取得

~~~
terraform plan -var-file=aws-handson.tfvars
~~~

環境適用

~~~
terraform apply -var-file=aws-handson.tfvars
~~~

apply 実行後、最終確認されるので「yes」をタイプ
~~~
... 略 ...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
  Enter a value: yes
~~~

terraform apply実行後、ロードバランサのdns名とRDSのエンドポイントが出力される。workdpressインストール時に利用する。
~~~
elb_dnsname = "http://aws-handson-lb-xxxxxxx.ap-northeast-1.elb.amazonaws.com"
rds_endpoint = "aws-handson-rds-wp-db.xxxxxxxxxxxxxxx.ap-northeast-1.rds.amazonaws.com:3306"
~~~

# WordPressにリクエスト

ブラウザに下記URLを貼り付け。後は[ハンズオン 5. WordPress の初期設定](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase5)の手順に沿って進める。必要な情報は、aws-handson.tfvarsや、apply後の出力内容で足りてるはず。
~~~
http://aws-handson-lb-xxxxxxx.ap-northeast-1.elb.amazonaws.com
~~~

# あとかたづけ

作成環境の一括削除  
変数外出ししている場合はdestroy時も「-var-file=aws-handson.tfvars」の指定が必要  
(変数解決できなくなるため)  

~~~
terraform destroy -var-file=aws-handson.tfvars
~~~

destroy 実行後も最終確認されるので「yes」をタイプ
~~~
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
~~~

以上