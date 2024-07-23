from __future__ import print_function
import os
import json
import boto3
import logging
import jmespath

from botocore.config import Config

# elb_arn_prefix="arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/"
elb_arn_prefix = os.environ['elb_arn_pre']

logger = logging.getLogger(__file__)
logger.setLevel(logging.INFO)

from botocore.exceptions import ClientError

elbv2_client = boto3.client('elbv2')


def get_lb_listener_arn(elb_arn):
    try:
        elb_listener_info = elbv2_client.describe_listeners(LoadBalancerArn=elb_arn)
#        elb_listener_arn = elb_listener_info['Listeners'][0]['ListenerArn']
        elb_listener_arn=jmespath.search("Listeners[?Protocol=='HTTPS'].ListenerArn", elb_listener_info)
        logger.info("listner arn is: {}".format(elb_listener_arn))
        return elb_listener_arn
    except ClientError as elbv2_response_error:
        logger.error('could not describe elb, error code is %s', elbv2_response_error.response['Error']['Code'])


def get_lb_rules(elb_listener_arn):
    try:
        elb_listener_rules = elbv2_client.describe_rules(ListenerArn=elb_listener_arn)
        action_list = []
        rule_dict = {} 
        rule_arns = []
#        print(len(elb_listener_rules))
        for rule in elb_listener_rules['Rules']:
            for action in rule['Actions']:
                action_type = action['Type']
#                print("action type: ", action_type)
                if action_type == "fixed-response":
                    rule_arn = rule['RuleArn']
                    rule_dict[action_type] = rule_arn
#                   print("rules are:", rule_dict)
                    rule_arns.append(rule_dict['fixed-response'])
#               else:
#                   rule_arn = "None"
        return rule_arns
    except ClientError as elbv2_response_error:
        logger.error('could not describe elb listener, error code is %s', elbv2_response_error.response['Error']['Code'])


def create_fixed_response_rule(elb_listener_arn):
    html = """
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>System Unavailable</title>
        <link rel="stylesheet" type="text/css" href="https://content.mobilehealthconsumer.com/DowntimePage/downtime.css">
        </head>
        <body>
        <div class="container">
        <div class="container_image">
        <img src="https://content.mobilehealthconsumer.com/DowntimePage/dog_bg_1.jpg" alt="">
        </div>
        <div class="container_content">
        <h1>Bear with us…</h1>
        <p style="font-size:35px;">We are making your experience better!</p>
        <img src="https://content.mobilehealthconsumer.com/DowntimePage/sign_1.png" alt="logo" name="logo">
        </div>
        </div>
        </body>
        </html>
    """

    try:
        elb_create_rule = elbv2_client.create_rule(
            ListenerArn=elb_listener_arn,
            Conditions=[{
                'Field': 'path-pattern',
                'Values': ['/*'],
            }],
            Priority=5,
            Actions=[{
                'Type': 'fixed-response',
                'FixedResponseConfig': {
                    'MessageBody': html,
                    'StatusCode': '200',
                    'ContentType': 'text/html',
                }
            }]
        )

    except ClientError as elbv2_response_error:
        logger.error('could not create rule, error code is %s', elbv2_response_error.response['Error']['Code'])


def create_api_fixed_response_rule(elb_listener_arn):
    try:
        elb_create_rule = elbv2_client.create_rule(
          ListenerArn=elb_listener_arn, 
          Conditions=[{
                      'Field': 'path-pattern',
                      'Values': ['/api/*'],
                     }],
          Priority=1,
          Actions=[{
                      'Type': 'fixed-response',
                      'FixedResponseConfig': {
                        'MessageBody': '{\'SiteIsDown\': True}',
                        'StatusCode': '200',
                        'ContentType': 'application/json',
                    }
                   }, 
                  ]
                 )
    except ClientError as elbv2_response_error:
        logger.error('could not create rule, error code is %s', elbv2_response_error.response['Error']['Code'])


def delete_fixed_response_rule(rule_arns):
    for rule_arn in rule_arns:
        # print ("rule arn is:", rule_arn)
        response = elbv2_client.delete_rule(RuleArn=rule_arn)


def lambda_handler(event, context):
    message = event['Records'][0]['Sns']['Message']
    if type(message) == str:
        try:
            message = json.loads(message)
        except JSONDecodeError as err:
            logging.error(f'message is type string but cannot load json: {err}')
    logger.info("msg is: {}".format(message))
    alarm_state = message["NewStateValue"]
    for test in message["Trigger"]["Dimensions"]:
        logger.info(test)
        if test["name"] == "LoadBalancer":
            elb_arn_suffix = test["value"]
        else:
            pass
        
    elb_arn = elb_arn_prefix + elb_arn_suffix
    
    logger.info("alarm state is: {}".format(alarm_state))
    
    returned_elb_listener_arn=get_lb_listener_arn(elb_arn)
    str_elb_listener_arn = returned_elb_listener_arn[0]
    logger.info("elb listener arn is: {}".format(str_elb_listener_arn))
    
    if alarm_state == "ALARM":
        create_fixed_response_rule(str_elb_listener_arn)
        create_api_fixed_response_rule(str_elb_listener_arn)
        logger.info("Alarming, creating rule")
    elif alarm_state == "OK":
        returned_rule_arns=get_lb_rules(str_elb_listener_arn)
        logger.info("rule ARN: {}".format(returned_rule_arns))
        if len(returned_rule_arns) > 0:
            delete_fixed_response_rule(returned_rule_arns)
            logger.info("Alarm cleared, deleting rule(s)")
        else:
            logger.info("cant delete rule, check listener and rules")
    else:
        pass

    return message
