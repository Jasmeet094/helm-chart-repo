#!/usr/bin/env python3

"""
This script applies tags to ec2 instances.

Name: create_tags.py
Usage: create_tags.py -e ofog -w
"""

import argparse
import logging

import boto3
import botocore

logging.basicConfig(level=logging.INFO)


# ruff: noqa: ANN001
def instances_by_tag(client, tag_key: str) -> list[dict]:
    """
    Describe instances by tag:Environment.

    Returns a list of Instance Id's and Names
    [
        {'Id': 'i-0f7fe938546d6386c', 'Name': 'ofoglogw1'},
        {'Id': 'i-0051ad9b6eed463e1', 'Name': 'ofogs01db1'},
    ]
    """
    data = client.describe_instances(
        Filters=[
            {
                "Name": "tag:Environment",
                "Values": [
                    tag_key,
                ],
            },
        ],
    )
    instances = []
    for i in data["Reservations"]:
        instance_id = i["Instances"][0]["InstanceId"]
        tags = i["Instances"][0]["Tags"]
        tag_name = [tag["Value"] for tag in tags if tag["Key"] == "Name"]
        try:
            instances.append({"Id": instance_id, "Name": tag_name[0]})
        except IndexError:
            logging.exception("error no name tag was found")

    return instances


def create_tags(client, instances: list, tags: list[dict]) -> None:
    """Apply tags to resources."""
    try:
        client.create_tags(DryRun=DRY_RUN, Resources=instances, Tags=tags)
        logging.info("successfully applied tag(s) to %s instances", len(instances))

    except botocore.exceptions.ClientError as e:
        resp_code = e.response["Error"]["Code"]
        if resp_code != "DryRunOperation":
            raise


def parse_args() -> argparse.Namespace:
    """Parse cli args."""
    parser = argparse.ArgumentParser(description="Apply tags to EC2 instance(s).")
    parser.add_argument(
        "-e",
        "--env",
        default="",
        help="Environment to apply tags.",
    )
    parser.add_argument(
        "-w",
        "--write",
        default=False,
        action="store_true",
        help="Apply proposed tag changes.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    ENV = args.env
    DRY_RUN = args.write
    TAGS = [{"Key": "PatchGroup", "Value": f"{ENV}"}]
    client = boto3.client("ec2", region_name="us-west-2")
    instances = instances_by_tag(client, ENV)
    if DRY_RUN:
        instances_ids = [i["Id"] for i in instances]
        create_tags(client, instances_ids, TAGS)
    else:
        logging.info("Instances to have tags applied: %s", instances)
        logging.info("to apply changes run: python3 create_tags.py -e %s -w", ENV)
