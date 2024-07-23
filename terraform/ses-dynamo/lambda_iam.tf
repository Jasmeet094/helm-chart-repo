resource "aws_iam_role" "policy" {
  name_prefix        = "Lambda_SNS_Dynamo"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
  "Action": "sts:AssumeRole",
  "Principal": {
    "Service": "lambda.amazonaws.com"
  },
  "Effect": "Allow"
}
]
}
EOF
}

resource "aws_iam_policy" "dynamo_and_lambda" {
  name_prefix = "dynamo_and_lambda-"
  path        = "/"
  description = "DynamoDB Access"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action" : [
          "sns:*"
      ],
      "Resource": [
        "${aws_sns_topic.SESBounce.arn}",
        "${aws_sns_topic.SESDelivery.arn}"
      ]
    },
    {
       "Sid": "Stmt1428510662000",
       "Effect": "Allow",
       "Action": [
           "DynamoDB:*"
       ],
       "Resource": [
           "${aws_dynamodb_table.dynamodb-table-delivery.arn}",
           "${aws_dynamodb_table.dynamodb-table-bounce.arn}"
       ]
    }]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.policy.name}"]
  policy_arn = "${aws_iam_policy.dynamo_and_lambda.arn}"
}
