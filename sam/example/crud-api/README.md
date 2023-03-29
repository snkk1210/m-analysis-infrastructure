# crud-api

## Example Local Build

- Create DynamoDB table ( local )
```
aws dynamodb create-table --table-name 'info' \
--attribute-definitions '[{"AttributeName":"key","AttributeType": "S"}]' \
--key-schema '[{"AttributeName":"key","KeyType": "HASH"}]' \
--provisioned-throughput '{"ReadCapacityUnits": 5,"WriteCapacityUnits": 5}' \
--endpoint-url http://localhost:8000
```

- dynamodb-local ( ./vars.json )
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

- Start ( local )
```
sam build
sam local start-api --env-vars vars.json --host 0.0.0.0
```

## Example AWS Deploy

- Deploy
```
sam build
sam deploy -g --parameter-overrides \
    ParameterKey=DYNAMOENDPOINT,ParameterValue="" \
    ParameterKey=TABLE,ParameterValue="info" \
    ParameterKey=ACAH,ParameterValue="*" \
    ParameterKey=ACAO,ParameterValue="*"
```

- Delete
```
sam delete
```

## Example Requests

### Local

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

### Prod

- Create
```
curl -X POST -H "Content-Type: application/json" -d '{"key" : "test-key" , "attr1" : "test-attr1" , "attr2" : "test-attr2"}' https://xxxxxxx.execute-api.us-east-1.amazonaws.com/Prod/info
```

- Read
```
curl https://xxxxxxx.execute-api.us-east-1.amazonaws.com/Prod/info
```

- Delete
```
curl -X POST -H "Content-Type: application/json" -d '{"key" : "test-key"}' https://xxxxxxx.execute-api.us-east-1.amazonaws.com/Prod/info/delete
```

## Example Commands

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