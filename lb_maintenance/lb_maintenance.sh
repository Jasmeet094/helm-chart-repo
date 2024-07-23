#!/bin/bash
read -r -d '' HELPMENU << EOM
Usage: "lb_maintenance.sh (create|destroy) LB_NAME"
- Choose the appropriate mode determined by whether you wish to create or destroy the fixed response rule on the specified load balancer.
- Replace LB_NAME in the example above with the name of the Load Balancer you wish to modify.
- IMPORTANT: Export your desired AWS profile to the AWS_PROFILE environment variable before execution.
EOM

function create {
# aws elbv2 create-rule only expects json args for conditions and actions arguments
    read -r -d '' CONDITION_JSON << EOM
[{
    "Field": "path-pattern",
    "Values": ["/*"]
}]
EOM

    read -r -d '' ACTION_JSON << EOM
[{
    "Type": "fixed-response",
    "FixedResponseConfig": {
        "MessageBody": "<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>System Unavailable</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"https://content.mobilehealthconsumer.com/DowntimePage/downtime.css\">\n</head>\n<body>\n<div class=\"container\">\n<div class=\"container_image\">\n<img src=\"https://content.mobilehealthconsumer.com/DowntimePage/dog_bg_1.jpg\" alt=\"\">\n</div>\n<div class=\"container_content\">\n<h1>Bear with us…</h1>\n<p style=\"font-size:35px;\">We are making your experience better!</p>\n</div>\n</div>\n</body>\n</html>",
        "StatusCode": "200",
        "ContentType": "text/html"
    }
}]
EOM
    aws elbv2 create-rule --region us-west-2 --listener-arn $LB_LISTENER_ARN --conditions "$CONDITION_JSON" --priority 1 --actions "$ACTION_JSON"
}

function destroy {
    LB_RULE_ARN=$(aws elbv2 describe-rules --region us-west-2 --listener-arn $LB_LISTENER_ARN --query 'Rules[0].RuleArn' --output text)
    LB_RULE_ACTION=$(aws elbv2 describe-rules --region us-west-2 --rule-arn $LB_RULE_ARN --query 'Rules[0].Actions[0].Type' --output text)
    if [ "$LB_RULE_ACTION" == "fixed-response" ]; then
        echo "Deleting fixed response rule"
        aws elbv2 delete-rule --region us-west-2 --rule-arn $LB_RULE_ARN 
    else
        echo "Highest priority rule is not fixed response rule. Skipping deletion."
    fi
}

if [[ "$1" =~ ^(create|destroy)$ ]]; then
    if [ -z "$2" ]; then
        echo "No load balancer name was passed."
        echo $HELPMENU
        exit
    else
        LB_NAME=$2
    fi
    LB_ARN=$(aws elbv2 describe-load-balancers --region us-west-2 --names $LB_NAME --query 'LoadBalancers[].LoadBalancerArn' --output text)
    LB_LISTENER_ARN=$(aws elbv2 describe-listeners --region us-west-2 --load-balancer-arn $LB_ARN --query 'Listeners[?Port==`443`].ListenerArn' --output text)
    $1
else
    echo "A valid mode was not provided. The valid modes are create and destroy."
    echo $HELPMENU
fi