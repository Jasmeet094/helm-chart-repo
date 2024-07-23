module "aws_vpc" {
  source = "git@github.com:FoghornConsulting/m-vpc?ref=v0.2.8"

  owner           = "${var.tag_costcenter}"
  tag_costcenter  = "${var.tag_costcenter}"
  tag_environment = "${var.environment}"
  tag_name        = "mhcnp"

  cidr_block = "172.20.0.0/16"

  subnet_map = {
    public   = 3
    private  = 3
    isolated = 0
  }
}
