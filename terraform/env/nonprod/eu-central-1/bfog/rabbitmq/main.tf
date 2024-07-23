provider "aws" {
  region = "us-west-2"
}

module "rabbitmq" {
  source = "../../../../../modules/rabbitmq"

  common_tags = {
    "App"         = "RabbitMQ"
    "Environment" = "ofog"
    "Terraform"   = "True"
  }
  environment       = "ofog"
  vpc_id            = data.aws_vpc.mhc.id
  broker_subnet_ids = data.aws_subnets.subnets.ids

  console_username = "mhcmquser123"
  console_password = "mhcmqpassword123"
}
