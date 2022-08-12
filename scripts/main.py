from os import getenv
import boto3
from botocore.exceptions import ClientError
import logging
import urllib3
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)
ec2client = boto3.client('ec2')
asgclient = boto3.client('autoscaling')

def notify(msg, webhook):
    http = urllib3.PoolManager()
    http.request('POST',webhook, body=json.dumps({"text": msg}), headers={'Content-Type': 'application/json'})

def get_ec2_details(instance_id):
    try:
        describe_tags_response = ec2client.describe_instances(InstanceIds=[instance_id])
        instance_tags = describe_tags_response['Reservations'][0]['Instances'][0]['Tags']
    except ClientError as e:
        error_message = "Unable to describe tags for instance id: {id}.".format(id=instance_id)
        logger.error( error_message + e.response['Error']['Message'])
        raise e
    for tag in instance_tags:
        if tag['Key'] == 'aws:autoscaling:groupName':
            asg_name = tag['Value']
    return asg_name


def detach_instance(instance_id, asg_name):
    webhook=getenv('webhook_url')
    try:
        response = asgclient.detach_instances(
            InstanceIds=[instance_id],
            AutoScalingGroupName=asg_name,
            ShouldDecrementDesiredCapacity=False
        )
        logger.info(response['Activities'][0]['Cause'])
        if getenv('webhook_notification_enabled', 'False').lower() == 'true':
            msg = "{0} is detached from ASG {1} successfully".format(instance_id, asg_name)
            notify(msg, webhook)
    except ClientError as e:
        error_message = "Unable to detach instance {id} from AutoScaling Group {asg_name}. ".format(
            id=instance_id,asg_name=asg_name)
        logger.error( error_message + e.response['Error']['Message'])
        if getenv('webhook_notification_enabled', 'False').lower() == 'true':
            msg = "Detaching {0} from ASG {1} failed".format(instance_id, asg_name)
            notify(msg, webhook)
        raise e

def lambda_handler(event, context):
    instance_id = event['detail']['instance-id']
    logger.info("Handling spot instance interruption for instance {0}".format(instance_id))
    asg_name= get_ec2_details(instance_id)
    detach_instance(instance_id, asg_name)
