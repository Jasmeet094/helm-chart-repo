#!/usr/bin/env python3

"""This script parses the log output of running the AWS-RunPatchBaseline SSM document to generate an override list."""

import logging
import re
from enum import Enum
from pathlib import Path

logging.basicConfig(level=logging.INFO)


class State(Enum):
    """Enumerates the possible states."""

    looking_for_before_fix = 1
    finding_patches = 2


# ruff: noqa: PLW0603
STATE = State.looking_for_before_fix
PACKAGES = []


def handle_before_fix(line: str) -> None:
    """Look for lines that contain before fix."""
    logging.debug("Entered handle_before_fix()")
    search_exp = "(Before fix)"
    if search_exp in line:
        logging.debug("Found %s in line", search_exp)
        global STATE
        STATE = State.finding_patches


def handle_finding_patches(line: str) -> None:
    """Look for lines that contain upgrade."""
    logging.debug("Entered handle_finding_patches()")
    search_exp = "Upgrade:"
    if search_exp in line:
        logging.debug("found %s in line", search_exp)
        packages = line.split(" ")
        packages = packages[2:]
        logging.info("found packages: %s", packages)
        for package in packages:
            match_res = re.findall(r"([^(]+)\(.+->([^)]+)", package)
            logging.debug("found regex match %s", match_res)
            PACKAGES.append(match_res)
        global STATE
        STATE = State.looking_for_before_fix

    elif "(Before fix)" in line:
        logging.error("Error found (Before fix) in line")
        msg = "Found before fix in finding patches"
        raise ValueError(msg)


def process_line(line: str) -> None:
    """Read line and determine if action needs to be taken."""
    logging.debug("Entered process_line() with %s", line)
    handlers = {
        State.looking_for_before_fix: handle_before_fix,
        State.finding_patches: handle_finding_patches,
    }
    handlers[STATE](line)
    logging.info("Current %s", STATE)


def write_yaml(packages: list) -> None:
    """Write packages to yaml file."""
    with Path("install_override_list.yml").open("w") as f:
        f.write("patches:\n")
        for package in packages:
            f.write(f"  - id: '{package[0][0]}'\n")
            f.write(f"    title: '{package[0][1]}'\n")


if __name__ == "__main__":
    with Path("patching.log").open(encoding="utf-8") as f:
        logging.info("Opened patch file")
        for line in f:
            process_line(line)

    logging.info("Writing install override list yml file")
    write_yaml(PACKAGES)
