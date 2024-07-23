module "aws_openvpn" {
  source = "git@github.com:FoghornConsulting/m-openvpn"

  vpcid         = "${var.vpcid}"
  dns_zone      = "${var.dns_zone}"
  region        = "${var.region}"
  ssh_key       = "${var.ssh_key}"
  subnets       = ["${var.subnets}"]
  sg_default    = "${var.sg_default}"
  subdomain     = "${var.subdomain}"
  instance_size = "${var.instance_size}"
  amis          = "${var.openvpn_ami_ids}"
}
