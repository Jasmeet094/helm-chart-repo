output "fogops_sns" {
  value = "${data.aws_sns_topic.sns_topic.arn}"
}
