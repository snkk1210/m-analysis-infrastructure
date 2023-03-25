import json
import boto3
import os

def lambda_handler(event, context):

    responseHeaders = {
      "Access-Control-Allow-Methods": "OPTIONS,GET",
      "Access-Control-Allow-Headers" : "*",
      "Access-Control-Allow-Origin": "*"
    }

    table = _get_database().Table(os.environ['TABLE'])

    res = table.scan()

    return {
        "headers": responseHeaders,
        "statusCode": 200,
        "body":  json.dumps(res['Items'], default=decimal_default_proc),
    }

def decimal_default_proc(obj):
    from decimal import Decimal
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

def _get_database():
    if (os.environ["DYNAMO_ENDPOINT"] == ""):
        endpoint = boto3.resource('dynamodb')
    else:
        endpoint = boto3.resource('dynamodb', endpoint_url=os.environ["DYNAMO_ENDPOINT"])
    return endpoint