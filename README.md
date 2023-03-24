# m-analysis-infrastructure

## What is this ?

SES receipt rule で受信したメールを加工して S3 に格納し、  
特定の S3 ディレクトリ配下にメールが格納された際に、別 Lambda を起動するパイプライン機構です。  
※ サンプルで Slack 通知用の Lambda を用意しています。　　

## Diagram

![poc02 5 drawio](https://user-images.githubusercontent.com/46625712/227524033-6665fcc7-5766-447c-8d13-6c0a641872b6.png)

## 何に使うの？

特定の From から届いたメールのみを処理したい場合に用いる想定です。  
S3 格納時に \${From}/\${Subject}/\${Date}/\${DisplayName}[dn]{random_string}.txt のフォーマットでメールを格納するので、\${From} を対象に EventBridge で監視 ⇒ Lambda 起動が可能です。  

サンプルで特定の From から届いたメールのみを Slack に通知する機構を用意していますが、別に Lambda 関数を用意すれば、EventBridge からキックが可能です。
