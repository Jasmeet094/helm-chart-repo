module "useast1" {
  providers = {
    "aws" = "aws.useast1"
  }

  source                 = "./module/"
  lambda_name            = "${var.fogops_us_east_1}"
  lambda_aws2redmine_arn = "${aws_lambda_function.aws2redmine.arn}"
}

module "useast2" {
  providers = {
    "aws" = "aws.useast2"
  }

  source                 = "./module/"
  lambda_name            = "${var.fogops_us_east_2}"
  lambda_aws2redmine_arn = "${aws_lambda_function.aws2redmine.arn}"
}

module "uswest1" {
  providers = {
    "aws" = "aws.uswest1"
  }

  source                 = "./module/"
  lambda_name            = "${var.fogops_us_west_1}"
  lambda_aws2redmine_arn = "${aws_lambda_function.aws2redmine.arn}"
}

module "uswest2" {
  providers = {
    "aws" = "aws.uswest2"
  }

  source                 = "./module/"
  lambda_name            = "${var.fogops_us_west_2}"
  lambda_aws2redmine_arn = "${aws_lambda_function.aws2redmine.arn}"
}
