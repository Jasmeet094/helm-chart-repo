resource "aws_sns_topic" "SESBounce" {
  name = "SES_Bounce"
}

resource "aws_sns_topic_policy" "SESBounce" {
  arn    = "${aws_sns_topic.SESBounce.arn}"
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {"AWS":"*"},
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "*"
      }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "SESBounce_notifications" {
  topic_arn = "${aws_sns_topic.SESBounce.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.sns_notification-sesbounce.arn}"
}

resource "aws_sns_topic" "SESDelivery" {
  name = "SES_Delivery"
}

resource "aws_sns_topic_policy" "SESDelivery" {
  arn    = "${aws_sns_topic.SESDelivery.arn}"
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {"AWS":"*"},
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "*"
      }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "SESDelivery_notifications" {
  topic_arn = "${aws_sns_topic.SESDelivery.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.sns_notification-sesdelivery.arn}"
}
