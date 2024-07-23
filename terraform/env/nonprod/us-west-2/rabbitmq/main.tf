provider "aws" {
  region = "us-west-2"
}

module "rabbitmq" {
  source = "../../../../modules/rabbitmq"

  common_tags = {
    "App"         = "RabbitMQ"
    "Environment" = "nonprod"
    "Terraform"   = "True"
  }
  environment       = "nonprod"
  vpc_id            = data.aws_vpc.mhc.id
  broker_subnet_ids = [data.aws_subnets.subnets.ids[0]]
  instance_type     = "mq.t3.micro"
  deployment_mode   = "SINGLE_INSTANCE"

  console_username = "mhcmquser123"
  console_password = "mhcmqpassword123"
}
