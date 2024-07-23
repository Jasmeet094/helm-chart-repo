terraform {
  backend "s3" {
    bucket         = "mhc-terraformstate-us-west-2-prod"
    key            = "terraform/env/prod/us-west-2/ofog/elasticache"
    dynamodb_table = "tf-state-locking"
    region         = "us-west-2"
    profile        = "mhc"
  }
}
