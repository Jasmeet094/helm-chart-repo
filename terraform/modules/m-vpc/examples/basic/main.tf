provider "aws" {
  region = "us-east-1"
}

module "main" {
  source = "../../"
}

module "secondary" {
  source = "../../"
}
