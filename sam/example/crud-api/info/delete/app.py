import json
import boto3
import os
from boto3.dynamodb.conditions import Key, Attr

def lambda_handler(event, context):

    responseHeaders = {
      "Access-Control-Allow-Methods": "OPTIONS,GET",
      "Access-Control-Allow-Headers" : os.environ['ACAH'],
      "Access-Control-Allow-Origin": os.environ['ACAO']
    }

    req = json.loads(event['body'])

    item = {
        'key': req['key']
    }

    table = _get_database().Table(os.environ['TABLE'])

    res = table.delete_item(Key=item, ReturnValues='ALL_OLD')

    return {
        "headers": responseHeaders,
        "statusCode": 200,
        "body": item,
    }

def _get_database():
    if (os.environ["DYNAMO_ENDPOINT"] == ""):
        endpoint = boto3.resource('dynamodb')
    else:
        endpoint = boto3.resource('dynamodb', endpoint_url=os.environ["DYNAMO_ENDPOINT"])
    return endpoint