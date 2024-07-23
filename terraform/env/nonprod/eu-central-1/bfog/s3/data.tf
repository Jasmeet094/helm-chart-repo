data "aws_vpc" "mhc" {
  filter {
    name   = "tag-value"
    values = ["MHCVPCv1"]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.mhc.id]
  }
  filter {
    name   = "tag-value"
    values = ["NonProduction*"]
  }
}
