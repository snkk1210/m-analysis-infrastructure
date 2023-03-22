import boto3
import json
import logging
import email
import random
import string
import os
import re

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    logger.info("Event: " + str(event))

    bucket_name = str(event['detail']['bucket']['name'])
    logger.info("Bucket: " + str(bucket_name))
    object_key = event['detail']['object']['key']
    object_list = event['detail']['object']['key'].split("/")

    for i in object_list:
        logger.info("Object: " + str(i))

    m_from = object_list[0]
    subject = object_list[1]
    date = object_list[2]
    content = read_s3_object(bucket_name, object_key)

    logging.info('From: ' + str(m_from))
    logging.info('Subject: ' + str(subject))
    logging.info('Date: ' + str(date))
    logging.info('Content: ' + str(content))


def read_s3_object(bucket_name, object_key):
    """
    Read files From S3.

    Parameters
    ----------
    bucket_name : string
        Bucket Name
    object_key : string
        File Name ( Path )

    Returns
    -------
    body : dict
        API Return Values
    """

    s3 = boto3.client("s3")

    try:
        res = s3.get_object(
            Bucket=bucket_name,
            Key=object_key
            )
        logger.info("Success: %s", res)
        body = res['Body'].read().decode('utf-8')
    except Exception as e:
        logger.error("Error: %s", e)
    return body

