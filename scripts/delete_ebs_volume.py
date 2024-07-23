#!/usr/bin/env python3

"""Delete unattached EBS volumes. This script reads in a list of volume-ids that are intended to be deleted."""

from pathlib import Path

import boto3


# ruff: noqa: ANN001
def delete_volume(client, volume_id: str) -> None:
    """Delete ebs volume."""
    client.delete_volume(
        VolumeId=volume_id,
    )


def describe_volume(client, volume_id: str) -> dict:
    """Describe ebs volume."""
    return client.describe_volumes(
        VolumeIds=[volume_id],
    )


if __name__ == "__main__":
    client = boto3.client("ec2", region_name="us-west-2")

    with Path("volumes-to-delete.txt").open(encoding="utf-8") as file:
        volumes_to_delete = [line.strip() for line in file]

    count = 0
    for vol in volumes_to_delete:
        volume_info = describe_volume(client, vol)
        create_time = volume_info["Volumes"][0]["CreateTime"]
        status = volume_info["Volumes"][0]["State"]
        if status == "available":
            print(f"deleting {vol} {status} {create_time}")
            delete_volume(client, vol)
            count += 1
    print(f"deleted {count} volumes")
