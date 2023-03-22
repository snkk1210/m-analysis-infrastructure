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
    
    message = json.loads(event['Records'][0]['Sns']['Message'])
    m_from = message['mail']['commonHeaders']['from'][0]
    date = message['mail']['commonHeaders']['date']
    subject = message['mail']['commonHeaders']['subject']
    content = message['content']
    email_obj = email.message_from_string(content)

    body = perth_mail_body(email_obj)
    logger.info("Body: " + str(body))

    fname = extract_mail_address(m_from).replace("/","[slash]") + "/" \
        + subject.replace("/","[slash]") \
        + "/" + date.replace("/","[slash]") \
        + "/" + extract_display_name(m_from) + "[dn]" + randomstr(20) + ".txt"
    logger.info("Fname: " + str(fname))

    res = put2s3(body, fname)
    logger.info("Response: " + str(res))

def perth_mail_body(email_obj):
    """
    Retrieve the body part of the mail.

    Parameters
    ----------
    email_obj : object structure

    Returns
    -------
    body : string
        body part of the mail
    """

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

def put2s3(body, fname):
    """
    Upload files to S3.

    Parameters
    ----------
    body : string
        File Contents
    fname : string
        File Name ( Path )

    Returns
    -------
    res : dict
        API Return Values
    """

    s3 = boto3.client("s3")

    try:
        res = s3.put_object(
            Bucket=os.environ['s3BucketName'],
            ACL='private',
            Body=body,
            Key=fname,
            ContentType='text/plain'
            )
        logger.info("Success: %s has been written.", fname)
        logger.info("Success: %s", res)
    except Exception as e:
        logger.error("Error: %s", e)
    return res

def randomstr(n):
    """
    Generate a random string.

    Parameters
    ----------
    n : int
        length of a character string
    
    Returns
    -------
        : string
        random string
    """
    return ''.join(random.choices(string.ascii_letters + string.digits, k=n))

def extract_mail_address(m_from):
    """
    Extracting email addresses from a string.

    Parameters
    ----------
    m_from : string
        String containing an email address
    
    Returns
    -------
        : list
        email addresses 
    """
    pattern = r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+'
    return re.findall(pattern, m_from)[0]

def extract_display_name(m_from):
    """    
    Extracting display name from a Mail From.

    Parameters
    ----------
    m_from : string
        String containing an email address
    
    Returns
    -------
        : string
        display name
    """
    delimiter = ' <'

    if delimiter in m_from:
        idx = m_from.find(delimiter)
        logger.info("There is Display Name")
        return m_from[:idx]
    else:
        logger.info("There is no Display Name")
        return "no_display_name"
