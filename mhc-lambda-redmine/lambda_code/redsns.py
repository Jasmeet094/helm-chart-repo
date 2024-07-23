#!/usr/bin/env python

from redmine import Redmine
import platform
from os.path import expanduser
import sys

key = '0f3cd83ae702704eb823aa4d47e33117555cf56c'
url = 'https://dev2.mobilehealthconsumer.com/redmine'
name = 'hitrust-evidence'
assigned_id = '39' # George's ID

# ToDo: Figure out why CA cert is not working
redmine = Redmine(url, key=key, requests={'verify': False})
project = redmine.project.get(name)
def lambda_handler(event, context):
    try:
        print("Event: %s" % event)

        if 'Subject' in event['Records'][0]['Sns']:
            if not(event['Records'][0]['Sns']):
                subject = "SNS Alert: " + event['Records'][0]['Sns']['Subject']
            else:
                subject = "SNS Alert"
        else:
            subject = "SNS Alert"

        message = "This is an automated report that came in via SNS. Please contact operations if you have any questions.\n\nSignature: %s" % event['Records'][0]['Sns']['Signature']

        data = event['Records'][0]['Sns']['Message']
        print(data)
        issue = redmine.issue.create(project_id=project.id, subject=subject, description=message, assigned_to_id=assigned_id)
        if "Report".lower() in subject.lower():
            extention = "csv"
        else:
            extention = "txt"
        file_path = get_file_path(issue=str(issue.id),extention=extention)

        with open(file_path, "w") as f:
            f.write(data)
        f.close()

        print "Issue created with the id of %s" % issue.id
        file_name = '%s.%s' % (issue.id, extention)

        result = redmine.issue.update(issue.id, uploads=([{'path': file_path, 'filename': file_name}]))

        print "Result of the update is: %s" % result
        return 0

    except Exception as e:
        print "Error: %s" % e


if __name__ == '__main__':
    event = { 'Records': [{   'EventVersion': '1.0',   'EventSubscriptionArn': 'arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c:e72de4ce-41e2-4c48-aa60-fe8d3e9b996e',   'EventSource': 'aws:sns',   'Sns': {     'SignatureVersion': '1',     'Timestamp': '2019-01-07T16:03:00.313Z',     'Signature': 'rFd2skrVoSuShJqSYskvkvxm0jMd1+EHFXbz0RGadkJqg+85QB9WvXzDUxBW/vesDBb3U3Xt8wLfpwY7+cm9uaBsxpV32v3pNmWbQSqV37sttWfSb2VfnQVfaiHjY9Rh2owKqo9Y554Hy8DjjP5iPP9gzKRQFrPsqPRmlFxUI1/pLOBWMBbuVV2ZYkfh7TVmMHFWjgJA7PwQvHexh2ozlk+gMadidYozWeCtvRztwojY3xKgwfLXILdjKhhP2DLSPg+SKt/LdPgmCTuiEB6vm9oghzKZUmrDMkEKaSKtHqithfAeODx66W/eHAaVP1HTspeixLnPajQqnoenCWPAsA==',     'SigningCertUrl': 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-ac565b8b1a6c5d002d285f9598aa1d9b.pem',     'MessageId': '74cc7348-7ae4-5e06-9a79-27e500902d72',     'Message': '{"version":"0","id":"cd1f03c1-f3d1-23f1-10c5-e64083e27a1e","detail-type":"AWS API Call via CloudTrail","source":"aws.ec2","account":"913835907225","time":"2019-01-07T16:02:15Z","region":"us-west-2","resources":[],"detail":{"eventVersion":"1.05","userIdentity":{"type":"IAMUser","principalId":"AIDAJ32G7TF77VYY2EN6G","arn":"arn:aws:iam::913835907225:user/matt","accountId":"913835907225","accessKeyId":"ASIA5JRG5LCM5LA6U67U","userName":"matt","sessionContext":{"attributes":{"mfaAuthenticated":"true","creationDate":"2019-01-07T14:18:59Z"}},"invokedBy":"signin.amazonaws.com"},"eventTime":"2019-01-07T16:02:15Z","eventSource":"ec2.amazonaws.com","eventName":"RevokeSecurityGroupIngress","awsRegion":"us-west-2","sourceIPAddress":"24.61.240.20","userAgent":"signin.amazonaws.com","requestParameters":{"groupId":"sg-0f4f552819eac34fc","ipPermissions":{"items":[{"ipProtocol":"tcp","fromPort":0,"toPort":65535,"groups":{},"ipRanges":{"items":[{"cidrIp":"127.0.0.1/32"}]},"ipv6Ranges":{},"prefixListIds":{}}]}},"responseElements":{"requestId":"abd1d11f-c69b-4745-9c7f-3fba233dbdec","_return":true},"requestID":"abd1d11f-c69b-4745-9c7f-3fba233dbdec","eventID":"58dbdc64-e66c-4e2a-85ad-346393d8fe09","eventType":"AwsApiCall"}}',     'MessageAttributes': {},     'Type': 'Notification',     'UnsubscribeUrl': 'https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c:e72de4ce-41e2-4c48-aa60-fe8d3e9b996e',     'TopicArn': 'arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c',     'Subject': None   } }]}
    content = ""
    lambda_handler(event=event,context=content)
