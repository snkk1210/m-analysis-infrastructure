import boto3
import json
import logging
import os
import re

from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
from urllib.parse import quote

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

    res = notify2slack(m_from, subject, date, content, object_key)

    logger.info("Response: " + str(res))


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

def notify2slack(m_from, subject, date, content, object_key):
    """
    Notify messages to slack.

    Parameters
    ----------
    m_from : string
        Mail From
    subject : string
        Mail Subject
    date : string
        Mail Date
    content : string
        Mail Content
    object_key : string
        File Name ( Path )
        
    Returns
    -------
    res : dict
        API Return Values
    """

    slack_message = {
        "channel": os.environ['channelName'],
        "icon_emoji": ":rotating_light:",
        "attachments": [
            {
                "color": "#FF0000",
                "title": "Email has been received.",
                "text": "<!here> \n *Content* \n ```%s``` \n" % (content),
                "fields": [
                    {
                        "title": "Date",
                        "value": date,
                        "short": True
                    },
                    {
                        "title": "Subject",
                        "value": subject,
                        "short": True
                    },
                    {
                        "title": "From",
                        "value": m_from,
                        "short": True
                    },
                    {
                        "title": "object_key",
                        "value": object_key,
                        "short": True
                    }
                ]

            }
        ]
    }

    req = Request(decrypt_hookurl(os.environ['HookUrl']), json.dumps(slack_message).encode('utf-8'))

    try:
        res = urlopen(req)
        res.read()
        logger.info("Message posted to %s", slack_message['channel'])
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)
    return res


def decrypt_hookurl(hookurl):
    """
    Notify messages to slack.

    Parameters
    ----------
    hookurl : string
        WebhookURL that may be encrypted
        
    Returns
    -------
    hookurl : string
        WebhookURL

    decrypted_hookurl : string
        Decrypted WebhookURL
    """

    if  "hooks.slack.com" in hookurl:
        logger.info("HookURL is not Encrypted")
        return hookurl
    else:
        logger.info("HookURL is Encrypted")
        decrypted_hookurl = boto3.client('kms').decrypt(
            CiphertextBlob=b64decode(hookurl),
            EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']}
        )['Plaintext'].decode('utf-8')
        return decrypted_hookurl