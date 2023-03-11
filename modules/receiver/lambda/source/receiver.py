import boto3
import json
import logging
import email
import random
import string
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    logger.info("Event: " + str(event))
    
    message = json.loads(event['Records'][0]['Sns']['Message'])
    mail = message['mail']

    logger.info("Message: " + str(message))

    timestamp = message['mail']['timestamp']
    m_from = message['mail']['commonHeaders']['from'][0]
    date = message['mail']['commonHeaders']['date']
    subject = message['mail']['commonHeaders']['subject'].replace(",","[comma]")
    content = message['content']

    email_obj = email.message_from_string(content)
    body = perth_mail_body(email_obj).replace(",","[comma]")

    fname = m_from + "/" + randomstr(20)
    csv = timestamp + "," + m_from + "," + date + "," + subject + "," + body

    res = put2s3(csv, fname)

    logger.info("CSV: " + str(csv))
    logger.info("Fname: " + str(fname))
    logger.info("Response: " + str(res))

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

def put2s3(csv, fname):

    s3 = boto3.client("s3")

    try:
        res = s3.put_object(
            Bucket=os.environ['s3BucketName'],
            ACL='private',
            Body=csv,
            Key=fname,
            ContentType='text/plain'
            )
        logger.info("Success: %s CSV has been written.", fname)
        logger.info("Success: %s", res)
    except Exception as e:
        logger.error("Error: %s", e)
    return res

def randomstr(n):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=n))