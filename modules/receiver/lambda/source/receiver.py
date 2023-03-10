import boto3
import json
import logging
import email
import os
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    logger.info("Event: " + str(event))
    
    message = json.loads(event['Records'][0]['Sns']['Message'])
    mail = message['mail']

    timestamp = message['mail']['timestamp']
    m_from = message['mail']['commonHeaders']['from']
    date = message['mail']['commonHeaders']['date']
    subject = message['mail']['commonHeaders']['subject']
    content = message['content']

    email_obj = email.message_from_string(content)
    body = perth_mail_body(email_obj)

    # NOTE: Logging
    logger.info("Message: " + str(message))
    logger.info("Mail: " + str(mail))
    logger.info("Timestamp: " + str(timestamp))
    logger.info("From: " + str(m_from))
    logger.info("Date: " + str(date))
    logger.info("Subject: " + str(subject))
    logger.info("Content: " + str(content))
    logger.info("Body: " + str(body))


def perth_mail_body(email_obj):

    body = ""
    for part in email_obj.walk():
        logger.info("maintype: " + part.get_content_maintype())
        if part.get_content_maintype() == 'multipart':
            continue

        attach_fname = part.get_filename()

    if not attach_fname:
        charset = str(part.get_content_charset())
        if charset:
            body += part.get_payload(decode=True).decode(charset, errors="replace")
        else:
            body += part.get_payload(decode=True)
    else:
        logger.info("There is Attach File")
        body += "Error: Attachments are not supported -> " + str(part.get_payload(decode=True))

    return body