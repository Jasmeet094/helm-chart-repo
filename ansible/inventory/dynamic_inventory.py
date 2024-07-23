#!/usr/bin/env python3

"""
Generate static and dynamic Ansible inventory.

This script uses boto3 to list all AWS EC2 instances and generate Ansible inventory,
grouping by tag values for a predefined list of tags. Given a set of tags/values like:

Env: [dev, stage, prod]
App: [app1, app2, app3]
Region: [east, west]

You will wind up with eight (8) inventory groups:

[dev, stage, prod, app1, app2, app3, east, west]

Each instance will be named after its Name tag, falling back to its internal DNS.
"""

import json
import logging
from argparse import ArgumentParser
from typing import Any

import boto3
import yaml


# ruff: noqa: ANN201
def parse_args():
    """Parse CLI arguments."""
    parser = ArgumentParser(description="ansible ec2 dynamic inventory builder")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--list", action="store_true", help="list all inventory hosts")
    group.add_argument("--host", action="store", help="specify instance hostname")
    group.add_argument("--generate", action="store_true", help="generate a static inventory file")
    return parser.parse_args()


# ruff: noqa: ANN001
def describe_instances(client) -> list:
    """Describe all EC2 instances."""
    try:
        paginator = client.get_paginator("describe_instances")
        page_iterator = paginator.paginate()
        instances = [i for p in page_iterator for res in p["Reservations"] for i in res["Instances"]]
    except Exception:
        logging.exception("unable to describe ec2 instances")
        raise
    return instances


def get_tag(key: str, tags_or_instance: list[dict[str, Any]] | dict[str, Any]) -> str:
    """
    Get the value of a resource tag from a list of tags by key.

    Since tags come in the format [{Key: "foo", Value: "bar"}, ...], you can't
    "just grab one real quick". The "key" parameter is the name of the tag for
    which you wish to get the value, and the "tags" can either be the list of
    tags from the "Tags" key of the instance dict, or the instance dict itself.
    """
    if isinstance(tags_or_instance, dict) and "Tags" in tags_or_instance and isinstance(tags_or_instance["Tags"], list):
        tags: list[dict[str, Any]] = tags_or_instance["Tags"]
    elif isinstance(tags_or_instance, list):
        tags = tags_or_instance
    else:
        raise ValueError("tags_or_instance must be a list of tags or an instance dict")

    for tag in tags:
        if tag["Key"] == key:
            return tag["Value"]
    return ""


def get_hostname(i: dict[str, Any]) -> str:
    """
    Get the hostname of an EC2 instance.

    Pass in the dictionary of an instance from eg describe_instances() and get back
    the ansible hostname of the instance (ie the name you pass to `ansible -l`). The
    hostname is the first of the following that is set:

    1. The Name tag
    2. Public DNS name
    3. Private DNS name
    4. Instance ID

    If none of those are set, a ValueError is raised.
    """
    hostname = get_tag("Name", i)
    if hostname:
        return hostname
    for key in ["PublicDnsName", "PrivateDnsName", "InstanceId"]:
        try:
            if i[key]:
                return i[key]
        except KeyError:
            pass
    raise ValueError("no hostname information found")


def get_tag_values(tag_names: list[str], instances: list) -> set:
    """Return a set of all values of all tag_names from all instances."""
    values = set()
    for instance in instances:
        for tag_name in tag_names:
            value = get_tag(tag_name, instance)
            values.add(value)
    values.discard("")  # Discard "empty string"
    return values


def filter_group_names(instances: list, tag_name: str) -> set:
    """Filter group names based on tag name."""
    groups = set()
    for i in instances:
        tag_value = get_tag(tag_name, i)
        if tag_value:
            groups.add(tag_value)
    return groups


def create_host_vars(instances: list) -> dict:
    """
    Generate a dict of hostvars.

    Note that right now, the only hostvar is 'ansible_host', which is set to the
    IP address of the instance. This functionality may change.
    """
    host_vars = {}
    for i in instances:
        name = get_hostname(i)
        try:
            private_ip_address = i["PrivateIpAddress"]
            host_vars[name] = {"ansible_host": private_ip_address}
        except KeyError:
            # This happens for stopped or terminating instances
            logging.exception("could not find instance private ip address")
    return host_vars


def create_host_groups(instances: list) -> dict:
    """Construct host groups based on AWS tags."""
    tags = ["Environment", "Role", "Shard"]
    keys = get_tag_values(tags, instances)
    host_groups = {key: {"hosts": {}} for key in keys}
    for instance in instances:
        name = get_hostname(instance)
        host_keys = {get_tag(tag, instance) for tag in tags}
        host_keys.discard("")
        for key in list(host_keys):
            host_groups[key]["hosts"][name] = {}
    return host_groups


def handle_host(hostname: str):
    """
    Handle invocations for a single host.

    This invocation is used by Ansible when running on a single host,
    such as `-l ps10w1`. It returns the inventory entry for that host.
    """
    ec2_client = boto3.client("ec2", region_name="us-west-2")
    instances = describe_instances(ec2_client)
    host_vars = create_host_vars(instances)

    try:
        host = host_vars[hostname]
        print(json.dumps(host))
    except KeyError:
        logging.exception("host not found: %s", hostname)
        raise


def handle_list():
    """
    Handle invocations to list all hosts.

    This invocation is used by Ansible unless it is running on a single host. It
    returns a JSON data structure with a specific format. For more information, see
    https://docs.ansible.com/ansible/latest/inventory_guide/intro_dynamic_inventory.html
    """
    ec2_client = boto3.client("ec2", region_name="us-west-2")
    instances = describe_instances(ec2_client)

    inventory = create_host_groups(instances)
    inventory["_meta"] = {"hostvars": create_host_vars(instances)}
    print(json.dumps(inventory))


def handle_generate():
    """
    Handle invocations to generate a static inventory.

    This invocation is for users that wish to update the static inventory. The
    inventory will be printed to stdout in yaml format.
    """
    ec2_client = boto3.client("ec2", region_name="us-west-2")
    instances = describe_instances(ec2_client)

    inventory = create_host_groups(instances)
    host_groups = create_host_vars(instances)
    inventory["all"] = {"hosts": host_groups}
    print(yaml.dump(inventory))


if __name__ == "__main__":
    args = parse_args()
    if args.generate:
        handle_generate()
    elif args.host:
        handle_host(args.host)
    elif args.list:
        handle_list()
