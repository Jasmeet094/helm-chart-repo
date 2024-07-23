#!/usr/bin/python27
import boto3
import json
import time
import dateutil.parser

# Helper class to convert a DynamoDB item to JSON.
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))

    processed = False
    DYNAMODB_TABLE = "SES_BOUNCES"

    DDBtable = boto3.resource('dynamodb').Table(DYNAMODB_TABLE)

    # Generic SNS headers
    SnsMessageId = event['Records'][0]['Sns']['MessageId']
    SnsPublishTime = event['Records'][0]['Sns']['Timestamp']
    SnsTopicArn = event['Records'][0]['Sns']['TopicArn']
    SnsMessage = event['Records'][0]['Sns']['Message']

    print("Read SNS Message with ID " + SnsMessageId + " published at " + SnsPublishTime)

    now = time.strftime("%c")
    LambdaReceiveTime = now;

    # SES specific fields
    SESjson = json.loads(SnsMessage)
    sesNotificationType = SESjson['notificationType']
    sesMessageId = SESjson['mail']['messageId']
    sesTimestamp = SESjson['mail']['timestamp'] #the time the original message was sent
    sender = SESjson['mail']['source']

    sesTimestamp_parsed = dateutil.parser.parse(sesTimestamp)
    sesTimestamp_seconds = sesTimestamp_parsed.strftime('%s')

    print("Processing an SES " + sesNotificationType + " with mID " + sesMessageId )

    if (sesNotificationType == "Bounce"):
        print "Processing SES bounce messsage"
        if 'reportingMTA' in SESjson['bounce']:
            reportingMTA = SESjson['bounce']['reportingMTA']
        else:
            print "No reportingMTA provided in bounce notification"
            reportingMTA = "UNKNOWN"

        bounceType = SESjson['bounce']['bounceType']
        bounceRecipients = SESjson['bounce']['bouncedRecipients']
        bounceType = SESjson['bounce']['bounceType']
        bounceSubType = SESjson['bounce']['bounceSubType']
        bounceTimestamp = SESjson['bounce']['timestamp'] # the time at which the bounce was sent by the ISP

        # There can be a seperate bounce reason per recipient IF it's not a suppression bounce
        for recipient in bounceRecipients:
            if 'emailAddress' in recipient:
                recipientEmailAddress = recipient['emailAddress']
            else:
                print "No recipient email provided in bounce notification"
                # print("Received event: " + json.dumps(event, indent=2))
                recipientEmailAddress = "UNKNOWN"

            if 'diagnosticCode' in recipient:
                diagnosticCode = recipient['diagnosticCode']
            else:
                print "No diagnosticCode provided in bounce notification"
                diagnosticCode = "UNKNOWN"

            print("Bounced recipient: " + str(recipientEmailAddress) + " reason: " + str(diagnosticCode))



            bounceTimestamp_parsed = dateutil.parser.parse(bounceTimestamp)
            bounceTimestamp_seconds = bounceTimestamp_parsed.strftime('Y-%m-%d %H-%M-%s')

            # Add entry to DB for this recipient
            Item={
                'recipientAddress': recipientEmailAddress,
                'sesMessageId': sesMessageId,
                'sesTimestamp': long(sesTimestamp_seconds),
                'bounceTimestamp': long(bounceTimestamp_seconds),
                'reportingMTA': reportingMTA,
                'diagnosticCode': diagnosticCode,
                'bounceType': bounceType,
                'bounceSubType': bounceSubType,
                'sender': sender.lower()
            }

            response = DDBtable.put_item(Item=Item)
            print("PutItem succeeded:")
            print(json.dumps(response, indent=4, cls=DecimalEncoder))

            processed = True
    elif sesNotificationType == "Complaint":
        print "Trying to process Complaint"
        list_of_emails = ""
        if len(SESjson['complaint']['complainedRecipients']) > 0:
            for email in SESjson['complaint']['complainedRecipients']:
                if list_of_emails == "":
                    list_of_emails = email['emailAddress']
                else:
                    list_of_emails = ", " + email['emailAddress']
        else:
            list_of_emails = "Unknown"

        complaintTimestamp = SESjson['complaint']['timestamp']
        complaintTimestamp_parsed = dateutil.parser.parse(complaintTimestamp)
        complaintTimestamp_seconds = complaintTimestamp_parsed.strftime('%s')

        complaintType = sesNotificationType
        complaintRecipients = list_of_emails
        complaintfeedbackID =  SESjson['complaint']['feedbackId']

        Item={
            'recipientAddress': list_of_emails,
            'sesMessageId': sesMessageId,
            'sesTimestamp': long(sesTimestamp_seconds),
            'bounceTimestamp': long(complaintTimestamp_seconds),
            'bounceType': complaintType,
            'sender': sender.lower()
        }
        response = DDBtable.put_item(Item=Item)
        print("PutItem succeeded:")
        print(json.dumps(response, indent=4, cls=DecimalEncoder))

        processed = True

    else:
        print("Unhandled notification type: " + sesNotificationType)

    return processed
