variable profile { default = "mhc" }
variable region { default = "us-west-2" }

#data lookup to vpc id

data "aws_vpc" "mhc-prod" {

  filter {
    name   = "tag:Name"
    values = ["MHCVPCv1"]
  }
}

resource "aws_flow_log" "mhc-prod" {
  iam_role_arn    = "${aws_iam_role.vpc-flow-logs.arn}"
  log_destination = "${aws_cloudwatch_log_group.vpc-flow-logs.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${data.aws_vpc.mhc-prod.id}"
}

resource "aws_cloudwatch_log_group" "vpc-flow-logs" {
  name = "vpc-flow-logs"
}

resource "aws_iam_role" "vpc-flow-logs" {
  name = "vpc-flow-logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cw-vpc-flow-logs" {
  name = "cw-vpc-flow-logs"
  role = "${aws_iam_role.vpc-flow-logs.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kinesis_stream" "vpc-flow-logs" {
  name             = "vpc-flow-logs-mhcprod"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "prod",
    Name        = "vpc-flow-logs-mhcprod"
  }
}

resource "aws_iam_role" "CW-to-kinesis" {
  name = "CW-to-kinesis"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.us-west-2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "CW-to-kinesis" {
  name = "CW-to-kinesis"
  role = "${aws_iam_role.CW-to-kinesis.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "kinesis:PutRecord",
      "Effect": "Allow",
      "Resource": "${aws_kinesis_stream.vpc-flow-logs.arn}"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_subscription_filter" "vpc-flow-logs-logfilter" {
  name            = "vpc-flow-logs-logfilter"
  role_arn        = "${aws_iam_role.CW-to-kinesis.arn}"
  log_group_name  = "${aws_cloudwatch_log_group.vpc-flow-logs.name}"
  filter_pattern  = "[version, account_id, interface_id, srcaddr != \"-\", dstaddr != \"-\", srcport != \"-\", dstport != \"-\", protocol, packets, bytes, start, end, action, log_status]"
  destination_arn = "${aws_kinesis_stream.vpc-flow-logs.arn}"
}
