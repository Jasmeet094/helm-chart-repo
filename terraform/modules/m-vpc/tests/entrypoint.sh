#!/bin/bash

EXIT_CODE=0
EXIT_TEXT=""

function test_code { 
  TEMP_CODE=$?
  if [ $TEMP_CODE -ne 0 ]
  then
    EXIT_CODE=$TEMP_CODE
  fi
}

cd tests

gem install bundler
bundle install
test_code 

if [ $EXIT_CODE -ne 0 ]
then
  echo Gem installed failed with exit code: $EXIT_CODE
  exit $EXIT_CODE
fi

kitchen converge
test_code

sleep 5

set -o pipefail
kitchen verify | tee verify.txt
test_code
if [ $EXIT_CODE -ne 0 ]
then 
  EXIT_TEXT=`cat verify.txt`
fi

kitchen destroy 
test_code

echo $EXIT_TEXT
echo "Exiting with status code: $EXIT_CODE"
exit $EXIT_CODE
