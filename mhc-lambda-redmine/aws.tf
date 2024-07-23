provider "aws" {
  alias   = "uswest2"
  profile = "mhc"
  region  = "us-west-2"
}

provider "aws" {
  alias   = "uswest1"
  profile = "mhc"
  region  = "us-west-1"
}

provider "aws" {
  alias   = "useast1"
  profile = "mhc"
  region  = "us-east-1"
}

provider "aws" {
  profile = "mhc"
  region  = "us-west-2"
}

provider "aws" {
  alias   = "useast2"
  profile = "mhc"
  region  = "us-east-2"
}
