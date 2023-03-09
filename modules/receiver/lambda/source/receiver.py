import boto3
import json
import logging
import os
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

    logger.info("Event: " + str(event))
    message = json.loads(event['Records'][0]['Sns']['Message'])
    logger.info("Message: " + str(message))

    mail = message['mail']
    logger.info("Mail: " + str(mail))

    timestamp = message['mail']['timestamp']
    logger.info("Timestamp: " + str(timestamp))

    m_from = message['mail']['commonHeaders']['from']
    logger.info("From: " + str(m_from))

    date = message['mail']['commonHeaders']['date']
    logger.info("Date: " + str(date))

    subject = message['mail']['commonHeaders']['subject']
    logger.info("Subject: " + str(subject))

    content = message['mail']['content']
    logger.info("Content: " + str(content))

