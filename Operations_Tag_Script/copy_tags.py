import boto3

def lambda_handler(event, context):
    instances = boto3.resource('ec2', region_name="us-west-2").instances.all()

    copyable_tag_keys = [ "Shard", "Environment", "Role", "Operations"]

    for instance in instances:
        copyable_tags = [t for t in instance.tags
                         if t["Key"] in copyable_tag_keys] if instance.tags else []
        if not copyable_tags:
            continue
        # Tag the EBS Volumes
        print(f"{instance.instance_id}: {instance.tags}")
        for vol in instance.volumes.all():
            print(f"{vol.attachments[0]['Device']}: {copyable_tags}")
            vol.create_tags(Tags=copyable_tags)
lambda_handler({},{})