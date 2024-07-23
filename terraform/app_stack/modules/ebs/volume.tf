
resource "aws_volume_attachment" "ebs_vol_attach" {
  device_name = "${var.device_path}"
  volume_id   = "${aws_ebs_volume.vol.id}"
  instance_id = "${var.instance_id}"
}

resource "aws_ebs_volume" "vol" {
  availability_zone = "${var.az}"
  size              = "${var.size}"
  type              = "gp3"
  encrypted         = "true"
  kms_key_id        = "${var.kms_key_id}"
  tags              = "${var.tags}"
  #  tags {
  #    Name = "${var.app_env}${var.shard}${var.server}-vol"
  #    Operations = ""
  #    MHCBackupFlag = "1"
  #  }
}
