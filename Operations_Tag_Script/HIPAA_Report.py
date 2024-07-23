#!/usr/bin/python

# Purpose: to add the operations tag to instances and all sub volumes
# Given Instance ID, Region
# None

from retrying import retry
import json
import boto3


# Purpose:get EC2 tags
# expects ec2 name
# Return dictionary of tags
@retry(stop_max_attempt_number=7, wait_exponential_multiplier=1000, wait_exponential_max=10000)
def get_tags_boto3(id_name):
    inst_dict = {}
    instance = resource.Instance(id_name)
    try:
        for inst_tag in instance.tags:
            inst_dict[inst_tag["Key"]] = inst_tag["Value"]
        return inst_dict
    except:
        return inst_dict


@retry(stop_max_attempt_number=7, wait_exponential_multiplier=1000, wait_exponential_max=10000)
def get_instance_from_filter_boto3(filters):
    return client_ec2.describe_instances(Filters=filters)

@retry(stop_max_attempt_number=7, wait_exponential_multiplier=1000, wait_exponential_max=10000)
def get_all_instances_boto3():
    return client_ec2.describe_instances(MaxResults=1000)

@retry(stop_max_attempt_number=7, wait_exponential_multiplier=1000, wait_exponential_max=10000)
def send_sns(message=None,sns_topic=None):
    if message == None or sns_topic == None:
        return None
    else:
        return client_sns.publish(TopicArn=sns_topic, Message=message, Subject="HIPAA Compliance Report")

if __name__ == '__main__':
    regions_in_use = ["us-east-1", "us-west-2", "us-west-1"]
    SNSTopic="arn:aws:sns:us-west-2:913835907225:HIPAA_Compliance_Report"

    dict_of_instances = {}
    dictionary_key_name = "HIPAA"
    ec2_headers = "Name,Instance_ID,State,InstanceType,LaunchTime,PrivateIpAddress,SecurityGroups,Region,PublicIpAddress\n"
    ec2_data = "\n"
    volume_headers = "Name,Volume_ID,State,Instance_attached_to,Location,Size,Type,Created"
    volume_data = "\n"
    for region in regions_in_use:
        client_ec2 = boto3.client('ec2', region)
        resource = boto3.resource('ec2', region)

        instances = get_all_instances_boto3()

        for ec2 in instances['Reservations']:
            for inst in ec2['Instances']:
                before_instance_tags = get_tags_boto3(inst['InstanceId'])
                if "Operations" in before_instance_tags:
                    before_operations_tag = json.loads(before_instance_tags["Operations"])
                    if dictionary_key_name in before_operations_tag:
                        # need schedule

                        all_sg = []
                        for sg in inst['SecurityGroups']:
			    all_sg.append(sg['GroupName'])
                        sg_string = ";".join(sorted(all_sg))
                        if 'PublicIpAddress' in inst:
                            public_ip = inst['PublicIpAddress']
                        else:
                            public_ip = ""
                        ec2_data = ec2_data + \
                                str(before_instance_tags['Name']) + "," + \
                                str(inst['InstanceId']) + "," + \
                                str(inst['State']['Name']) + "," +\
                                str(inst['InstanceType']) + "," + \
                                str(inst['LaunchTime']) + "," + \
                                str(public_ip) + "," + \
                                str(sg_string) + "," + \
                                str(region) + "," + \
                                str(public_ip) + "\n"

        for volume in client_ec2.describe_volumes()['Volumes']:
            if 'Tags' in volume:
                for tag in volume['Tags']:
                    if 'Operations' in tag['Key']:
                        name_value = None
                        for tag_interation_2 in volume['Tags']:
                            if 'Name' in tag_interation_2['Key']:
                                name_value = tag_interation_2['Value']
                            if not name_value:
                                name_value = "No Name tag"
                            for attachment in volume['Attachments']:
                                if not 'InstanceId' in attachment:
                                    volume_to_instance = "Not Attached"
                                else:
                                    volume_to_instance = attachment['InstanceId']

                            volume_data = volume_data + \
                                str(name_value) + "," + \
                                str(volume['VolumeId']) + "," + \
                                str(volume['State']) + "," +\
                                str(volume_to_instance) + "," +\
                                str(volume["AvailabilityZone"]) + "," + \
                                str(volume['Size']) + "," + \
                                str(volume['VolumeType']) + "," + \
                                str(volume['CreateTime']) + "," + \
                                str(region)  + "\n"
    ec2_content = ec2_headers + ec2_data
    volume_content = volume_headers + volume_data
    client_sns = boto3.client('sns', "us-west-2")
    print send_sns(message=ec2_content,sns_topic=SNSTopic)
    print send_sns(message=volume_content,sns_topic=SNSTopic)