#!/bin/bash

# Purpose: To check to see if a volume is encrpyted
# Expects: A path to a file
# Return: String and exit code to nagios

DATA=$(cryptsetup luksUUID $1 2>&1)

if [ $? -ne 0 ] ; then
    echo "Error: Volume $1 not encrypted. Not getting an valid response back form cryptsetup luksUUID $1"
    exit 2
else
    echo "OK: UUID of volume $1 is $DATA"
    exit 0
fi
