# crud-api

## Example ENV ( vars.json )

- dynamodb-local
```
{
    "Parameters": {
      "DYNAMO_ENDPOINT": "http://xxx.xxx.xxx.xxx:8000",
      "TABLE": "info",
      "ACAH": "*",
      "ACAO": "*"
    }
}
```

## Example commands

- Create DynamoDB table ( local )
```
aws dynamodb create-table --table-name 'info' \
--attribute-definitions '[{"AttributeName":"key","AttributeType": "S"}]' \
--key-schema '[{"AttributeName":"key","KeyType": "HASH"}]' \
--provisioned-throughput '{"ReadCapacityUnits": 5,"WriteCapacityUnits": 5}' \
--endpoint-url http://localhost:8000
```

- Create DynamoDB table
```
aws dynamodb create-table --table-name 'info' \
--attribute-definitions '[{"AttributeName":"key","AttributeType": "S"}]' \
--key-schema '[{"AttributeName":"key","KeyType": "HASH"}]' \
--provisioned-throughput '{"ReadCapacityUnits": 5,"WriteCapacityUnits": 5}' \
--region us-east-1
```

- Delete DynamoDB table
```
aws dynamodb delete-table --table-name 'info' --region us-east-1
```

- Start ( local )
```
sam build
sam local start-api --env-vars vars.json --host 0.0.0.0
```

## Example requests

- Create
```
curl -X POST -H "Content-Type: application/json" -d '{"key" : "test-key" , "attr1" : "test-attr1" , "attr2" : "test-attr2"}' http://127.0.0.1:3000/info
```

- Read
```
curl http://127.0.0.1:3000/info
```

- Delete
```
curl -X POST -H "Content-Type: application/json" -d '{"key" : "test-key"}' http://127.0.0.1:3000/info/delete
```

## Example Deploy


- Deploy
```
sam build
sam deploy -g
```

- Delete
```
sam delete
```