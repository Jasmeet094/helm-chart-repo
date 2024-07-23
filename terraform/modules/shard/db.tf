resource "aws_eip" "eip_db" {
  vpc  = true
  tags = merge(local.interum_tags, { "Role" = "Database", "Name" = (join("", [var.base_name, "db1"])) })
}

resource "aws_eip_association" "db" {
  instance_id   = aws_instance.db.id
  allocation_id = var.create_eips ? aws_eip.eip_db.id : var.eip_db
}

resource "aws_ebs_volume" "postgres" {
  count             = var.create_secondary_volumes ? 1 : 0
  availability_zone = aws_instance.db.availability_zone
  size              = var.create_secondary_volumes ? 10 : null
  tags              = merge(local.interum_tags, { "Role" = "Database", "Name" = (join("", [var.base_name, "db1-postgres"])) })
  kms_key_id        = contains(var.shards_anthem, var.base_name) ? var.kms_anthem : var.kms_default
  encrypted         = true
}

resource "aws_volume_attachment" "postgres" {
  count       = var.create_secondary_volumes ? 1 : 0
  device_name = "/dev/sdp"
  volume_id   = aws_ebs_volume.postgres[0].id
  instance_id = aws_instance.db.id
}

resource "aws_ebs_volume" "mongo" {
  count             = var.create_secondary_volumes ? 1 : 0
  availability_zone = aws_instance.db.availability_zone
  size              = var.create_secondary_volumes ? 10 : null
  tags              = merge(local.interum_tags, { "Role" = "Database", "Name" = (join("", [var.base_name, "db1-mongo"])) })
  kms_key_id        = contains(var.shards_anthem, var.base_name) ? var.kms_anthem : var.kms_default
  encrypted         = true
}

resource "aws_volume_attachment" "mongo" {
  count       = var.create_secondary_volumes ? 1 : 0
  device_name = "/dev/sdm"
  volume_id   = aws_ebs_volume.mongo[0].id
  instance_id = aws_instance.db.id
}

resource "aws_instance" "db" {
  ami           = var.ami_db == "" ? "ami-031b1f872d286c170" : var.ami_db
  instance_type = var.db_instance_type

  tags        = merge(local.interum_tags, { "Role" = "Database", "Name" = (join("", [var.base_name, "db1"])) })
  volume_tags = merge(local.interum_tags, { "Role" = "Database" })
  subnet_id   = var.subnet_id # data.aws_subnets.selected.id
  # this script looks up the volume, looks up what letter it is, and puts it into the thing. This is how the web servers are seen as sdv sdm sdd etc. setup upon first running of an instance launching
  # This is magic, which will need to be revisited when we move to a newer version of ubuntu
  # This same userdata script is similar to the older app stack one, which is done in a way that makes sense for the newer (non legacy) shards
  user_data              = templatefile("${path.module}/template/user_data.sh.tpl", { hostname = join("", [var.base_name, "db1"]) })
  vpc_security_group_ids = var.web_security_group
  key_name               = var.key_name
  iam_instance_profile   = var.db_instance_profile != "" ? var.db_instance_profile : "DBServer"

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_default
    volume_type           = "gp3"
  }

  lifecycle {
    ignore_changes = all
  }
}


resource "aws_route53_record" "dbpvt" {
  zone_id = var.r53_zone_id
  name    = join("", [var.base_name, "db1", "pvt"])
  type    = "A"
  ttl     = "300"
  records = [aws_instance.db.private_ip]
}
