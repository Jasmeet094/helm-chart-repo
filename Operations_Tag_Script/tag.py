import copy
import logging
import os
import re
import boto3

logging.basicConfig(level=os.environ.get('LOG_LEVEL', 'INFO'))

ec2 = boto3.client('ec2', "us-west-2")
logger = logging.getLogger(__name__)

def get_tags(info):
    print("testing %s"% info)
    detailed = re.search("((p|pc|pt|da|q|qa|qb|op|qc|qd|st)(s\d\d|log)(db|w).*)|(ss|Management_Server|Strong|jenkins|Open).*", info, re.IGNORECASE)
    try:      
        if detailed:
            if detailed.groups()[4] == None:
                env = detailed.groups()[1]
                shard = detailed.groups()[2]
                servertype = detailed.groups()[3]
                if servertype == "db":
                    servertype = "Database"
                elif servertype == "w":
                    servertype = "Web"
                else:
                    servertype = "Unknown"
                print("description: {}, env: {}, shard: {} servertype: {}".format(info, env, shard, servertype)) 
                tags = ansible_dict_to_boto3_tag_list({"Environment": env, "Shard": shard, "Role": servertype})
                print(tags)
            else:
                env = "ss"
                print("description: {}, env: {}".format(info, env)) 
                tags = ansible_dict_to_boto3_tag_list({"Environment": env})
        else:
            tags = ansible_dict_to_boto3_tag_list({})
    except:
        tags = ansible_dict_to_boto3_tag_list({})
    return tags

def tag_snapshots():
    snapshots = {}
    for response in ec2.get_paginator('describe_snapshots').paginate(OwnerIds=['self']):
        snapshots.update([(snapshot['SnapshotId'], snapshot) for snapshot in response['Snapshots']])

    good = []
    bad = []
    count = 0
    for snapshot in snapshots:
        raw_snapshot = snapshots[snapshot]
        # import pdb;pdb.set_trace()
        m = re.search("^(.*) Backup ([0-9]{4}-[0-9]{2}-[0-9]{2})", raw_snapshot['Description'])

        if m:
            volumeName = m.groups()[0]
            backupDate = m.groups()[1]
            description = raw_snapshot['Description']

            #tags = get_tags(description)
        
            # ec2.create_tags(Resources=[raw_snapshot['SnapshotId']], Tags=tags, DryRun=False)   
        else:
            
            if 'Tags' in raw_snapshot:
                org_tags = boto3_tag_list_to_ansible_dict(raw_snapshot['Tags'])
                if 'Name' in org_tags:
                    # print("Trying to parse via Name tag, %s" % org_tags['Name'])
                    tags = get_tags(org_tags['Name'])
                    # print(tags)
                    # import pdb;pdb.set_trace()
                    if not(tags == []):
                        ec2.create_tags(Resources=[raw_snapshot['SnapshotId']], Tags=tags)  
                    else:
                        print("skipping %s" % org_tags['Name'])
                    


        


def tag_everything():
    tag_snapshots()
    #tag_volumes()


def boto3_tag_list_to_ansible_dict(tags_list):
    tags_dict = {}
    for tag in tags_list:
        if 'key' in tag and not tag['key'].startswith('aws:'):
            tags_dict[tag['key']] = tag['value']
        elif 'Key' in tag and not tag['Key'].startswith('aws:'):
            tags_dict[tag['Key']] = tag['Value']

    return tags_dict


def ansible_dict_to_boto3_tag_list(tags_dict):
    tags_list = []
    for k, v in tags_dict.items():
        tags_list.append({'Key': k, 'Value': v})

    return tags_list


def handler(event, context):
    tag_everything()


if __name__ == '__main__':
    tag_everything()