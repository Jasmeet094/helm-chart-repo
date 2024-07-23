resource "aws_instance" "instance" {
  ami               = "${var.ami}"
  tenancy           = "default"
  instance_type     = "${var.instance_type}"
  key_name          = "${var.key}"
  # availability_zone = "${var.az}"

  vpc_security_group_ids = "${var.security_group_ids}"

  subnet_id            = "${var.subnet}"
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${var.profile}"

  tags = {
    Name        = "${var.env}${var.shard}${var.server}" # TODO: "${var.env}-${var.shard}${var.server}"
    Ansible     = "True"
    Environment = "${var.env}"
    # Role        = "${coalesce(local.database_server, local.admin_server, local.web_server)}"
    Shard       = "${var.shard}"
    # Not putting the backup tag in here bc its apart of our building process to add to builda 
  }

  volume_tags = {
    Name        = "${var.env}${var.shard}${var.server}-root" # TODO: "${var.env}-${var.shard}${var.server}"
    Operations  = "${var.env == "p" ? "{\"HIPAA\": \"T\"}" : ""}"
    Ansible     = "True"
    Environment = "${var.env}"
    # Role        = "${coalesce(local.database_server, local.admin_server, local.web_server)}"
    Shard       = "${var.shard}"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = "${var.root_volume_size}"
    encrypted   = "true"
    kms_key_id  = "${var.kms_key_id}"
  }
}
