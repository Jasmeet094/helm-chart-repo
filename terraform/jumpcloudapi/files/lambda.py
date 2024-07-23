import boto3
import os
import json


def get_region():
    import os
    try:
        return os.environ['AWS_DEFAULT_REGION']
    except Exception as e:
        print(e)
        return "us-west-2"


# Purpose: Download file from s3
# Expects: S3 bucket, s3 file, temp location
# returns: Key from File
def download_api_key(s3_bucket, key, download_location):
    try:
        s3_conn_resource = boto3.resource('s3',
                                      get_region())
        print("Trying to download the file")
        s3_conn_resource.meta.client.download_file(
            s3_bucket,
            key,
            download_location)
        print("Downloaded the file!")
    except Exception as e:
        print("Error downloading " +
                      s3_bucket +
                      "/" +
                      key +
                      ". Error was %s" % e)
        return None


# Purpose: Get API Key from S3
# Expects: S3 bucket
# returns: Key from File
def get_api_key(s3_bucket, key, download_location):
    try:
        download_api_key(s3_bucket, key, download_location)
        with open(download_location, 'r') as myfile:
            data=myfile.read().replace('\n', '')
        print("reading file")
        print("API_KEY=%s" % data)
        return data
    except Exception as e:
        print("Error reading the file. Error was %s" % e)
        return None


def get_date(timeoffset=60):
    from datetime import datetime, timezone, timedelta
    local_time = datetime.now(timezone.utc).astimezone() - timedelta(minutes=timeoffset)
    # print(local_time.isoformat())
    return local_time.isoformat()


def preform_api_call(api_key):
    import urllib
    import requests
    # print("API_KEY: %s" % api_key)
    custom_headers = {'Content-Type': 'application/json', 'x-api-key': "%s" % api_key}
    payloaddict = {'startDate': get_date()}
    # print(payloaddict)
    payload = urllib.parse.urlencode(payloaddict)
    print("Payload: %s" % payload)
    # print("custom_headers: %s" % custom_headers)
    r = requests.get("https://events.jumpcloud.com/events", params=payload, headers=custom_headers)
    print(r.text, r.status_code)
    return json.loads(r.text)

def if_exist_create_stream(group_name, stream_name):
    try:
        client = boto3.client('logs', get_region())
        response = client.create_log_stream(
            logGroupName="%s" % group_name,
            logStreamName="%s" % stream_name
        )
        return True
    except:
        return None


def create_cloudwatch_event(group_name, result):
    print("RESULT in create_cloudwatch_event: %s" % result)
    import re
    import datetime
    print("MESSAGE: %s" % result['details']['message'])
    data = re.match("^user\b([a-z]+)\b.*$", result['details']['message'].lower())
    print("DATA: %s" % data)
    if data:
        user = data.group(1)
    else:
        user = ""

    line = "%s,%s,%s,%s,%s" % (result['sourceIP'],
                               result['time'],
                               result['type'],
                               result['details']['message'],
                               user)
    print("LINE: %s" % line)
    client = boto3.client('logs', get_region())


    stream = result['details']['system']['id']
    if_exist_create_stream(group_name, stream)
    sequence = client.describe_log_streams(
        logGroupName="%s" % group_name,
        logStreamNamePrefix="%s" % stream)
    print("SEQUENCE: %s" % sequence)
    if 'uploadSequenceToken'  in sequence['logStreams'][0]:
        sq_iq=sequence['logStreams'][0]['uploadSequenceToken']
    else:
        sq_iq = None
    if sq_iq:
        print("INSIDE IF has sequence")
        res = client.put_log_events(
            logGroupName="%s" % group_name,
            logStreamName="%s" % stream,
            logEvents=[
                {
                    'timestamp': int((datetime.datetime.utcnow() - datetime.datetime(1970, 1, 1)).total_seconds()) * 1000,
                    'message': "%s" % line
                }
            ],
            sequenceToken="%s" % sq_iq
        )
    else:
        print("INSIDE IF DOES NOT HAVE sequence")
        res = client.put_log_events(
            logGroupName="%s" % group_name,
            logStreamName="%s" % stream,
            logEvents=[
                {
                    'timestamp': int((datetime.datetime.utcnow() - datetime.datetime(1970, 1, 1)).total_seconds()),
                    'message': "%s" % line
                }
            ]
        )
    print("FINAL: %s" % json.dumps(res))
    return res

def lambda_handler(event, context):
    print("EVENT: %s" % event)
    print("context: %s" % context)
    temp_event = event
    arn_split = context.invoked_function_arn.split(":")
    arn_region, arn_name = arn_split[3], context.function_name


    s3_bucket = "mhc-secure"
    s3_object = "jumpcloud_api_key.txt"
    download_location = "/tmp/api_key.txt"

    # If this lambda function is kicked of by a scheduled timer,
    # this will recusively itself to query regions for
    # volumes matching certain tags.
    if ("source", "aws.events") in event.items():
        temp_event['source'] = 'self.api_key'
        temp_event['api_key'] = get_api_key(s3_bucket, s3_object, download_location)

        lambda_conn = boto3.client('lambda', get_region())
        resp = lambda_conn.invoke(
            FunctionName=context.function_name,
            Payload=json.dumps(temp_event),
            InvocationType='Event'
        )
        print("events resp: "+str(resp))
        print("Payload1: %s" % json.dumps(temp_event))

    elif ("source", "self.api_key") in event.items():
        api_key = temp_event['api_key']
        print("API_KEY: %s" % api_key)
        result = preform_api_call("%s" % api_key)
        temp_event['source']='self.record'
        print("RESULT: %s" % result)
        for item in result:
            print("ITEM: %s" % item)
            temp_event['record']=item
            lambda_conn = boto3.client('lambda', get_region())
            resp = lambda_conn.invoke(
                FunctionName=context.function_name,
                Payload=json.dumps(temp_event),
                InvocationType='Event'
            )
            print("events resp: "+str(resp))
            print("Payload2: %s" % json.dumps(temp_event))

    elif ("source", "self.record") in event.items():
        record = temp_event['record']
        print("Record_Round_3: %s" % record)
        response = create_cloudwatch_event('mhc_jumpcloud_logs', record)
        print("FINAL: %s" % json.dumps(response))
        return response
