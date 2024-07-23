#!/usr/bin/python

# Purpose: to add the operations tag to instances and all sub volumes
# Given Instance ID, Region
# None

import sys
import boto3
from retrying import retry
import json

# Purpose:get EC2 tags
# expects ec2 name
# Return dictionary of tags
#@retry(stop_max_attempt_number=7, wait_exponential_multiplier=1000, wait_exponential_max=10000)
def get_tags_boto3(id_name):
    inst_dict = {}
    instance = resource.Instance(id_name)
    try:
        for inst_tag in instance.tags:
            inst_dict[inst_tag["Key"]] = inst_tag["Value"]
        return inst_dict
    except:
        return inst_dict


# Purpose: Set Tag
# expects: string, string, string
# Return: nothing
# @retry(stop_max_attempt_number=7, wait_exponential_multiplier=1000, wait_exponential_max=10000)
def set_tags_boto3(resource_id, tags):
    print(client.create_tags(Resources=[resource_id], Tags=tags))


def get_instance_from_filter_boto3(filters):
    return client.describe_instances(Filters=filters)

def get_volumes_by_instance_boto3(instance_id=None):
    volumes = []
    try:
        volume_response = client.describe_volumes(
            Filters=[
                {
                    'Name': 'attachment.instance-id',
                    'Values': [instance_id]
                }
            ]
        )
        for volume in volume_response['Volumes']:
            volume = resource.Volume(volume['VolumeId'])
            volumes.append(volume)
    except Exception as e:
        log.error("Couldn't retrieve volume information: '%s'", e, exc_info=sys.exc_info())
        return None
    return volumes


instance_id = sys.argv[1]
current_region = sys.argv[2]

client = boto3.client('ec2', current_region)
resource = boto3.resource('ec2', current_region)

list_of_items = []
list_of_items.append(instance_id)
if instance_id.lower().startswith("i-"):
    print("Instance so Im getting the volumes too")
    for volume in get_volumes_by_instance_boto3(instance_id):
         list_of_items.append(volume.id)

for item in list_of_items:
    # Get tags
    before_instance_tags = get_tags_boto3(instance_id)
    print(before_instance_tags)

    # check if operations tag exists
    if "Operations" in before_instance_tags:
        ## if exist checks to see if key "Type" exist and it is HIPAA
        before_operations_tag = json.loads(before_instance_tags['Operations'])
        before_operations_tag['HIPAA'] = "T"
        json_data = before_operations_tag  # add Tag called operations with dictionary Key:"Type" Value: HIPAA
    else:
        json_data = {"HIPAA": "T"}

    set_tags_boto3(instance_id, [{'Key': 'Operations', 'Value': json.dumps(json_data)}])