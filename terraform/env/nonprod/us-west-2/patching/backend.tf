terraform {
  backend "s3" {
    bucket         = "mhc-terraformstate-us-west-2-prod"
    key            = "terraform/env/nonprod/us-west-2/patching"
    dynamodb_table = "tf-state-locking"
    region         = "us-west-2"
  }
}
