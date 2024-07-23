resource "aws_eip" "eip" {
  instance = "${module.web.id}"
  vpc      = true
}

resource "aws_eip" "eip_w2" {
  instance = "${module.web_w2.id}"
  vpc      = true
}

resource "aws_eip" "eip_db" {
  instance = "${module.db.id}"
  vpc      = true
}

module "web" {
  source = "../instance"

  #ami = "ami-6aa26412" #${data.aws_ami.base_image.id}"
  ami                 = "${var.ami}"
  eip                 = "${aws_eip.eip.public_ip}"
  server              = "w1"
  env                 = "${var.env}"
  az                  = "${var.region}${var.az[var.shard]}"
  subnet              = "${var.subnet}"
  profile             = "${var.profiles["web"]}"
  shard               = "${var.shard}"
  key                 = "${var.key}"
  domain              = "${var.domain}"
  r53_zone_id         = "${var.r53_zone_id}"
  r53_private_zone_id = "${var.r53_private_zone_id}"
  kms_key_id          = "${var.kms_key_id}"
  security_group_ids = [
    "${var.security_groups["app"]}",
    "${var.security_groups["external_services"]}",
    "${var.security_groups["general"]}"
  ]
  instance_type = "${var.instance_type}"
}

module "web_w2" {
  source = "../instance"

  ami                 = "${var.ami}"
  eip                 = "${aws_eip.eip_w2.public_ip}"
  server              = "w2"
  env                 = "${var.env}"
  az                  = "${var.region}${var.az[var.shard]}"
  subnet              = "${var.subnet}"
  profile             = "${var.profiles["web"]}"
  shard               = "${var.shard}"
  key                 = "${var.key}"
  domain              = "${var.domain}"
  r53_zone_id         = "${var.r53_zone_id}"
  r53_private_zone_id = "${var.r53_private_zone_id}"
  kms_key_id          = "${var.kms_key_id}"
  security_group_ids = [
    "${var.security_groups["app"]}",
   "${var.security_groups["external_services"]}",
    "${var.security_groups["general"]}"
  ]
  instance_type = "${var.instance_type}"
}

module "web_sdf" {
  source = "../ebs"

  instance_id = "${module.web.id}"
  device_path = "/dev/sdf"
  az          = "${var.region}${var.az[var.shard]}"
  app_env     = "${var.env}"
  shard       = "${var.shard}"
  server      = "w1"
  region      = "${var.region}"
  size        = 10
  kms_key_id  = "${var.kms_key_id}"
  tags = {
    Name               = "${var.env}${var.shard}w1-datamhc"
    Operations         = "${var.env == "p" ? jsonencode(map("HIPPA", "T")) : ""}"
    # mhc-prod-backup    = "${var.env == "p" ? "true" : "false"}"
    # mhc-nonprod-backup = "${var.env == "p" ? "false" : "true"}"
    # anthem-prod-backup = "${var.env == "p" ? "true" : "false"}"
  }
}


module "web_sdf_w2" {
  source = "../ebs"

  instance_id = "${module.web_w2.id}"
  device_path = "/dev/sdf"
  az          = "${var.region}${var.az[var.shard]}"
  app_env     = "${var.env}"
  shard       = "${var.shard}"
  server      = "w2"
  region      = "${var.region}"
  size        = 10
  kms_key_id  = "${var.kms_key_id}"
  tags = {
    Name               = "${var.env}${var.shard}w2-datamhc"
    Operations         = "${var.env == "p" ? jsonencode(map("HIPPA", "T")) : ""}"
    # mhc-prod-backup    = "${var.env == "p" ? "true" : "false"}"
    # mhc-nonprod-backup = "${var.env == "p" ? "false" : "true"}"
    # anthem-prod-backup = "${var.env == "p" ? "true" : "false"}"
  }
}

module "db" {
  source = "../instance"

  eip                 = "${aws_eip.eip_db.public_ip}"
  ami                 = "${var.ami}"
  server              = "db1"
  env                 = "${var.env}"
  az                  = "${var.region}${var.az[var.shard]}"
  subnet              = "${var.subnet}"
  profile             = "${var.profiles["db"]}"
  shard               = "${var.shard}"
  key                 = "${var.key}"
  domain              = "${var.domain}"
  r53_zone_id         = "${var.r53_zone_id}"
  r53_private_zone_id = "${var.r53_private_zone_id}"
  kms_key_id          = "${var.kms_key_id}"
  security_group_ids = [
    "${var.security_groups["db"]}",
    "${var.security_groups["external_services"]}",
    "${var.security_groups["general"]}"
  ]
  instance_type = "t3.large"
}

module "db_sdf" {
  #postgres DB volume
  source = "../ebs"

  instance_id = "${module.db.id}"
  device_path = "/dev/sdp"
  az          = "${var.region}${var.az[var.shard]}"
  app_env     = "${var.env}"
  shard       = "${var.shard}"
  server      = "w1"
  region      = "${var.region}"
  size        = 20
  kms_key_id  = "${var.kms_key_id}"
  tags = {
    Name               = "${var.env}${var.shard}db01-postgres"
    Operations         = "${var.env == "p" ? jsonencode(map("HIPPA", "T")) : ""}"
    # mhc-prod-backup    = "${var.env == "p" ? "true" : "false"}"
    # mhc-nonprod-backup = "${var.env == "p" ? "false" : "true"}"
    # anthem-prod-backup = "${var.env == "p" ? "true" : "false"}"
  }
}

module "db_sdg" {
  #mongo DB volume
  source = "../ebs"

  instance_id = "${module.db.id}"
  device_path = "/dev/sdm"
  az          = "${var.region}${var.az[var.shard]}"
  app_env     = "${var.env}"
  shard       = "${var.shard}"
  server      = "w1"
  region      = "${var.region}"
  size        = 20
  kms_key_id  = "${var.kms_key_id}"
  tags = {
    Name               = "${var.env}${var.shard}db01-mongo"
    Operations         = "${var.env == "p" ? jsonencode(map("HIPPA", "T")) : ""}"
    # mhc-prod-backup    = "${var.env == "p" ? "true" : "false"}"
    # mhc-nonprod-backup = "${var.env == "p" ? "false" : "true"}"
    # anthem-prod-backup = "${var.env == "p" ? "true" : "false"}"
  }
}


module "web_w3" {
  source = "../instance"

  ami                 = "${var.ami}"
  eip                 = "${aws_eip.eip_w2.public_ip}"
  server              = "w3"
  env                 = "${var.env}"
  az                  = "${var.region}${var.az[var.shard]}"
  subnet              = "${var.subnet}"
  profile             = "${var.profiles["web"]}"
  shard               = "${var.shard}"
  key                 = "${var.key}"
  domain              = "${var.domain}"
  r53_zone_id         = "${var.r53_zone_id}"
  r53_private_zone_id = "${var.r53_private_zone_id}"
  kms_key_id          = "${var.kms_key_id}"
  security_group_ids = [
    "${var.security_groups["app"]}",
   "${var.security_groups["external_services"]}",
    "${var.security_groups["general"]}"
  ]
  instance_type = "${var.instance_type}"
}


module "web_sdf_w3" {
  source = "../ebs"

  instance_id = "${module.web_w3.id}"
  device_path = "/dev/sdf"
  az          = "${var.region}${var.az[var.shard]}"
  app_env     = "${var.env}"
  shard       = "${var.shard}"
  server      = "w3"
  region      = "${var.region}"
  size        = 10
  kms_key_id  = "${var.kms_key_id}"
  tags = {
    Name               = "${var.env}${var.shard}w4-datamhc"
    Operations         = "${var.env == "p" ? jsonencode(map("HIPPA", "T")) : ""}"
    # mhc-prod-backup    = "${var.env == "p" ? "true" : "false"}"
    # mhc-nonprod-backup = "${var.env == "p" ? "false" : "true"}"
    # anthem-prod-backup = "${var.env == "p" ? "true" : "false"}"
  }
}
