# m-analysis-infrastructure

## What is this ?

SES receipt rule で受信したメールを加工して S3 に格納し、  
特定の S3 ディレクトリ配下にメールが格納された際に、別 Lambda を起動するパイプライン機構です。  
※ サンプルで Slack 通知用の Lambda を用意しています。　　

./sam ディレクトリ配下に API Gateway / Lambda / DynamoDB を用いた簡単な crud 実装用の SAM 一式を配置しました。   
※ 詳細は同ディレクトリの README を参照下さい。　　

## Diagram

![poc09 drawio](https://user-images.githubusercontent.com/46625712/228535505-69ba9c9e-f568-4e8b-b52b-f2ebf1cb2944.png)

## 何に使うの？

特定の From から届いたメールを一連のパイプライン処理に渡すケースで用いる想定です。  
SES で受信したメールを S3 に \${From}/\${Subject}/\${Date}/\${DisplayName}[dn]{random_string}.txt のフォーマットで格納するので、\${From} を対象に EventBridge で受信検知 ⇒ Lambda 起動が可能です。  

サンプルで特定の From から届いたメールのみを Slack に通知する機構を用意していますが、他 Lambda 関数を用意すれば、EventBridge からキックが可能です。

## Usage

- Create .tf file to load module from template file
```
cp -p notifier.tf.example notifier.tf
cp -p receiver.tf.example receiver.tf
```

- apply

```
terraform init
terraform plan
terraform apply
```