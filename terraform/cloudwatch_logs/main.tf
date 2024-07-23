provider "aws" {
  region  = "us-west-2"
  profile = "mhc"
}

data "aws_kms_alias" "cwl" {
  name = "alias/cloudwatch"
}

resource "aws_cloudwatch_log_group" "prod_defaults" {
  count      = "${length(var.loggroup_default_list)}"
  name       = "/prod${element(var.loggroup_default_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "prod_web" {
  count      = "${length(var.loggroup_web_list)}"
  name       = "/prod${element(var.loggroup_web_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "prod_db" {
  count      = "${length(var.loggroup_db_list)}"
  name       = "/prod${element(var.loggroup_db_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "qa_defaults" {
  count      = "${length(var.loggroup_default_list)}"
  name       = "/qa${element(var.loggroup_default_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "qa_web" {
  count      = "${length(var.loggroup_web_list)}"
  name       = "/qa${element(var.loggroup_web_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "qa_db" {
  count      = "${length(var.loggroup_db_list)}"
  name       = "/qa${element(var.loggroup_db_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "dev_defaults" {
  count      = "${length(var.loggroup_default_list)}"
  name       = "/dev${element(var.loggroup_default_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "dev_web" {
  count      = "${length(var.loggroup_web_list)}"
  name       = "/dev${element(var.loggroup_web_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}

resource "aws_cloudwatch_log_group" "dev_db" {
  count      = "${length(var.loggroup_db_list)}"
  name       = "/dev${element(var.loggroup_db_list, count.index)}"
  kms_key_id = "${data.aws_kms_alias.cwl.arn}"
}