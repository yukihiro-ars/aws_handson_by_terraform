# スケーラブルウェブサイト構築ハンズオンを通してTerraformをかじってみた

- [スケーラブルウェブサイト構築ハンズオンを通してTerraformをかじってみた](#スケーラブルウェブサイト構築ハンズオンを通してterraformをかじってみた)
- [はじめに](#はじめに)
- [STEP1のゴール](#step1のゴール)
- [前提知識](#前提知識)
  - [用語](#用語)
    - [Region（リージョン）](#regionリージョン)
    - [Availability Zone（AZ）](#availability-zoneaz)
    - [VPC（Virtual Private Cloud）](#vpcvirtual-private-cloud)
    - [サブネット](#サブネット)
    - [インターネットゲートウェイ](#インターネットゲートウェイ)
    - [ルートテーブル](#ルートテーブル)
    - [ELB（Elastic Load balancing）](#elbelastic-load-balancing)
    - [セキュリティグループ](#セキュリティグループ)
    - [ターゲットグループ](#ターゲットグループ)
    - [EC2（Elastic Compute Cloud）](#ec2elastic-compute-cloud)
    - [RDS（Relational Database Service）](#rdsrelational-database-service)
    - [IAM（Identity and Access Management）](#iamidentity-and-access-management)
    - [AMI（マシンイメージ）](#amiマシンイメージ)
- [Terraform とは](#terraform-とは)
  - [IaCのメリット](#iacのメリット)
  - [競合技術](#競合技術)
  - [コーディング](#コーディング)
  - [Terraformを使うメリット](#terraformを使うメリット)
- [Terraformでハンズオン](#terraformでハンズオン)
  - [STEP1でのハンズオンの流れ](#step1でのハンズオンの流れ)
  - [0.Terraform下準備](#0terraform下準備)
  - [1.VPCの作成](#1vpcの作成)
  - [2. Amazon EC2 の作成](#2-amazon-ec2-の作成)
  - [3. Amazon RDSの作成](#3-amazon-rdsの作成)
  - [4. ELBの作成](#4-elbの作成)
  - [5. WordPressの初期設定](#5-wordpressの初期設定)
- [雑感](#雑感)

# はじめに

インフラ知識(弱)、AWS歴1年弱(クラウドプラクティショナーをもとに勉強し始めて3ヶ月)、Terraformは当然初めてとなるAPエンジニアが、[スケーラブルウェブサイト構築ハンズオン](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP)のシステムをTerraformを通して構築して得たTerraformの知識と、雑感を共有したいと思います。  
スケーラブルウェブサイト構築ハンズオンで最終的に作成されるシステム構成は、複数のAZ(アベイラビリティゾーンに)APサーバとRDSを配置し、Webレイヤーは負荷分散且つ冗長構成に、DBレイヤーは可用性を高める構成となっていますが、今回はSTEP1ということでその途中段階までをゴールとしています。
![ハンズオンのシステム構成完成図](https://static.us-east-1.prod.workshops.aws/public/d6be7f14-44e1-4950-a656-1fdd321bdf8e/static/index.png)

# STEP1のゴール

STEP1ではロードバランサを配置しつつも、ウェブレイヤー、DBレイヤーともにシングルAZに配置した構成としています。

![STEP1のゴール](https://static.us-east-1.prod.workshops.aws/public/d6be7f14-44e1-4950-a656-1fdd321bdf8e/static/overview/images/phase5/00.png)

# 前提知識

ここではハンズオンで登場する用語にしぼって簡単に説明

## 用語

### Region（リージョン）

- AWSがサービスを提供している国の地域のこと  
（東京リージョン、オレゴンリージョン、ロンドンリージョンなど）

### Availability Zone（AZ）

- リージョン内の区分のこと  
- AZ内に複数のデータセンターを持つ
- 耐障害性を高めるため一つのリージョン内に複数のAZがある

### VPC（Virtual Private Cloud）

- AWS上の閉域（自分専用の）ネットワーク  
- VPCを作成して、その中にサーバーなどを構築していく

### サブネット

- VPC内でさらに細かく区切った任意のネットワークの範囲。  
- Webサーバーはパブリックサブネットに配置し、データベースはプライベートサブネットに構築するなど、用途による切り分けができる。（パブリックサブネットとプライベートサブネットの違いは、インターネットと直接通信するかどうか）

### インターネットゲートウェイ

- インターネットとVPCのつなぎ役

### ルートテーブル

- VPCはルールに従ってルートと呼ばれるネットワーク経路を選択する。そのルールが記載されたテーブル

### ELB（Elastic Load balancing）

- ロードバランサーサービス
- 外部リクエストを複数サーバに振り分ける
- 複数種類あるが今回使うのはWebサービス向けのALB(Application Load Balancer)  
   他にもNLB(Network ...)とかあるみたい

### セキュリティグループ

- 関連付けられたリソースのINとOUTのトラフィックを制御する  
  ハンズオン(STEP1)ではELB - EC2 - RDS間のI/Oを制御

### ターゲットグループ

- リクエストをルーティングするために使う  
  ロードバランサにくっついてくる  

### EC2（Elastic Compute Cloud）

- 仮想サーバー
- ひとつひとつのサーバーはEC2インスタンスと呼ばれる。
- WindowsServer、LinuxなどOSの選択可能

### RDS（Relational Database Service）

- AWSが提供するRDBのサービス
- Amazon Aurora、Oracle、SQL Server、PostgreSQL、MySQL、MariaDBから選択可能

### IAM（Identity and Access Management）

- 簡単に言うとユーザーアカウント機能
- ルートユーザー（AWSに登録したアカウント）との差別化を図る
- 各サービスのアクセス権限を設定できる

### AMI（マシンイメージ）

- AWSが管理するマシンイメージ
- 独自のマシンイメージを作成することもできる  
  独自のAMIを作成する手順がハンズオンにも含まれるが、STEP1では対象外

# Terraform とは

正直まだ語れるほどの経験がないのでなんとも言えませんが、、  
Infrastructure as Code (IaC) を実現するソフトウェアツールです。  
開発元はHashiCorp。創業者は[日系三世のミッチェル・ハシモト氏](https://www.publickey1.jp/blog/17/hashicorp_interview02.html)

## IaCのメリット

- コスト削減
- デプロイメントの高速化
- エラーの減少
- インフラストラクチャの一貫性の向上
- 構成ドリフトの排除

※参考 [Red Hat IaC (Infrastructure as Code) とは ](https://www.redhat.com/ja/topics/automation/what-is-infrastructure-as-code-iac)より  
※構成ドリフトはググった結果、管理できていない設定差異のこととぼんやり解釈

## 競合技術

- AWS Cloud Formation | AWSが提供するIaCサービス
- Azure Resource Manager | Microsoftが提供するリソースグループを管理するサービス([参考](https://business.ntt-east.co.jp/content/cloudsolution/column-147.html))
- などなど、、

## コーディング

HashiCorp Configuration Language(HCL)を用いてJSONぽい宣言型のプログラミング言語を用いて記述

## Terraformを使うメリット

- 異なるクラウドサービスに同一言語(HCL)で対応できる

- 充実した[ドキュメント](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)  

- リソースの一括削除

   ハンズオンの[リソースの削除工程](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/cleanup)は結構な作業量、料金を払っている身としては削除漏れも気になるところ  

   対してTerraformの場合、Terraformで準備したリソースにつては以下のdestroyコマンドで一括削除ができる  

   ~~~
   terraform destroy
   ~~~

# Terraformでハンズオン

ここからはダラダラとハンズオンとコードの対比でお送りします。

## STEP1でのハンズオンの流れ

[全体の流れ1～5(のはじめぐらい)](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/overview)
WordPress立ち上げまでを実施

## 0.Terraform下準備

利用するTerraformバージョンやawsプロフィール、リージョンを指定
~~~
main.tf あたりを見ながら
~~~

## 1.VPCの作成

- ハンズオンの流れ  
[https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase1](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase1)

- コードディング  
  ~~~
  network.tf あたりを見ながら
  ~~~ 

## 2. Amazon EC2 の作成

- ハンズオンの流れ  
[https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase2](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase2)

- コードディング  
  ~~~
  ec2.tf、ins_wp.sh あたりを見ながら
  ~~~ 

## 3. Amazon RDSの作成

- ハンズオンの流れ  
[https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase3](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase3)

- コードディング  
  ~~~
  rds.tf あたりを見ながら
  ~~~ 

## 4. ELBの作成

- ハンズオンの流れ  
[https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase4](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase4)

- コードディング  
  ~~~
  elb.tf あたりを見ながら
  ~~~ 

## 5. WordPressの初期設定

- ハンズオンの流れ  
[https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase5](https://catalog.us-east-1.prod.workshops.aws/workshops/47782ec0-8e8c-41e8-b873-9da91e822b36/ja-JP/hands-on/phase5)

- コードディング  
- 
  ~~~
  outputs.tf あたりを見ながら
  ~~~ 

# 雑感

APエンジニアがAWSのリソース間の依存関係のイメージをつかむには良い入口だと思いました。([destroyコマンド](#terraformを使うメリット)も心強い)  
また私のような初学者でもハンズオンのようにある程度やることが決まっていれば、[ドキュメント](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment)を見ながらある程度なんとか構築することは出来ました(インバウンド、アウトバウンドのアタリはカンニングしましたが)。インフラ知識があればもっとスムーズだと思います。
