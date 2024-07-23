provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

module "us_east_1" {
  source = "../../"
}

module "us_east_2" {
  providers = {
    aws = aws.us_east_2
  }
  source = "../../"
}

module "us_west_1" {
  providers = {
    aws = aws.us_west_1
  }
  source = "../../"
}

module "us_west_2" {
  providers = {
    aws = aws.us_west_2
  }
  source = "../../"
}
