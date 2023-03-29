import json
import boto3
import os
import logging
import datetime
from boto3.dynamodb.conditions import Key, Attr
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

    req = json.loads(event['body'])

    item = {
        'key': req['key'],
        'attr1': req['attr1'],
        'attr2': req['attr2'],
        'time': str(datetime.datetime.now())
    }

    logger.info("Item: " + str(item))

    try:
        table = _get_database().Table(os.environ['TABLE'])
        res = table.put_item(Item=item)
        logger.info("Respons: " + str(res))
    except ClientError as e:
        logger.error("Error: %s", e)

    return {
        "headers": responseHeaders,
        "statusCode": 200,
        "body": str(item),
    }

def _get_database():
    if (os.environ["DYNAMO_ENDPOINT"] == ""):
        endpoint = boto3.resource('dynamodb')
    else:
        endpoint = boto3.resource('dynamodb', endpoint_url=os.environ["DYNAMO_ENDPOINT"])
    return endpoint