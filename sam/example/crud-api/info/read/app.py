import json
import boto3
import os
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    logger.info("Event: " + str(event))

    responseHeaders = {
      "Access-Control-Allow-Methods": "OPTIONS,GET",
      "Access-Control-Allow-Headers" : os.environ['ACAH'],
      "Access-Control-Allow-Origin": os.environ['ACAO']
    }

    try:
        table = _get_database().Table(os.environ['TABLE'])
        res = table.scan()
    except ClientError as e:
        logger.error("Error: %s", e)

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