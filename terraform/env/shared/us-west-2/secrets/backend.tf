terraform {
  backend "s3" {
    bucket         = "mhc-terraformstate-us-west-2-prod"
    key            = "terraform/env/shared/us-west-2/secrets"
    dynamodb_table = "tf-state-locking"
    region         = "us-west-2"
  }
}
