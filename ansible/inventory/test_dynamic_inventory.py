import pickle
from pathlib import Path

import boto3
import pytest
from dynamic_inventory import describe_instances, get_tag


@pytest.fixture()
def ec2_instances():
    """
    Load sample ec2 instance data.

    The sample data is loaded and unpickled from a file called
    sample_describe_instances.pickle in the same directory as this file. If
    that file does not exist, it will be created from the first 100 results
    of dynamic_inventory.describe_instances.
    """
    testdata_path = Path(__file__).parent / "sample_describe_instances.pickle"
    if not testdata_path.is_file():
        ec2_client = boto3.client("ec2", region_name="us-west-2")
        instance_data = describe_instances(ec2_client)
        with testdata_path.open("wb") as fp:
            pickle.dump(instance_data[:100], fp)
    with testdata_path.open("rb") as fp:
        # ruff: noqa: S301
        return pickle.load(fp)


def test_get_tag(ec2_instances):
    """Verify that get_tag gets tags and handles a tag called Tags properly."""
    # It should get tags
    tags = [{"Key": "foo", "Value": "bar"}, {"Key": "baz", "Value": "other"}]
    assert get_tag("foo", tags) == "bar"

    # It should not be fooled by a tag called Tags
    tags.append({"Key": "Tags", "Value": "psyche!"})
    assert get_tag("Tags", tags) == "psyche!"

    # It should return "empty string" if a tag doesn't exist
    assert not get_tag("DoesntExist", ec2_instances[0])
