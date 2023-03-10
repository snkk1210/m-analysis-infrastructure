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

    content = message['content']
    logger.info("Content: " + str(content))


    email_obj = email.message_from_string(content)

    body = ""
    body_html = ""
    body_text = ""
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

        if part.get_content_type() == "text/html":
            body_html += body
        elif part.get_content_type() == "text/plain":
            body_text += body
    else:
        attach_data = part.get_payload(decode=True)
        logger.info("There is Attach File")
        body += "Error: Attachments are not supported"

    logger.info("AttachData: " + str(attach_data))
    logger.info("Text: " + str(body_text))
    logger.info("HTML: " + str(body_html))
    logger.info("Body: " + str(body))