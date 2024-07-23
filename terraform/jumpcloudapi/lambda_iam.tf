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
  name_prefix = "s3_and_lambda-"
  path        = "/"
  description = "s3 Access"
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
          "s3:Get*",
          "lambda:Invoke*",
          "logs:*"
      ],
      "Resource": "*"
    }]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.policy.name}"]
  policy_arn = "${aws_iam_policy.dynamo_and_lambda.arn}"
}
