terraform {
  backend "s3" {
    bucket         = "mhc-terraformstate-us-west-2-prod"
    key            = "terraform/env/nonprod/us-west-2/rabbitmq"
    dynamodb_table = "tf-state-locking"
    region         = "us-west-2"
    profile        = "mhc"
  }
}
