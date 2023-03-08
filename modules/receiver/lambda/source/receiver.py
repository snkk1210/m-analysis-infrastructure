import boto3
import json
import logging
import os
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

    logger.info("Event: " + str(event))
