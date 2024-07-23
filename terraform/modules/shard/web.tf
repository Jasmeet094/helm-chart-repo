resource "aws_eip" "eip_web" {
  count = length(local.webserver_info)
  vpc   = true
  tags  = merge(local.interum_tags, { "Role" = "Database", "Name" = (join("", [var.base_name, "db1"])) })
}

resource "aws_eip_association" "web" {
  count         = length(local.webserver_info)
  instance_id   = aws_instance.web[count.index].id
  allocation_id = var.create_eips ? aws_eip.eip_web[count.index].id : element(var.eip_web, count.index)
}

locals {
  # ToDo: fix this!
  webserver_info = length(var.ami_web) == 0 ? ["ami-031b1f872d286c170"] : var.ami_web
}

resource "aws_ebs_volume" "mhcdata" {
  count             = var.create_secondary_volumes ? length(local.webserver_info) : 0
  size              = var.create_secondary_volumes ? 10 : null
  tags              = merge(local.interum_tags, { "Role" = count.index == 0 ? "Admin" : "Web", "Name" = (join("", [var.base_name, "w", (count.index + 1), "-data"])) })
  kms_key_id        = contains(var.shards_anthem, var.base_name) ? var.kms_anthem : var.kms_default
  encrypted         = true
  availability_zone = aws_instance.web[count.index].availability_zone
}

resource "aws_volume_attachment" "mhcdata" {
  count       = var.create_secondary_volumes ? length(local.webserver_info) : 0
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.mhcdata[count.index].id
  instance_id = aws_instance.web[count.index].id
}

resource "aws_instance" "web" {
  count         = length(local.webserver_info)
  ami           = element(local.webserver_info, count.index)
  instance_type = var.web_instance_type

  tags                   = merge(local.interum_tags, { "Role" = count.index == 0 ? "Admin" : "Web", "Name" = (join("", [var.base_name, "w", (count.index + 1)])) })
  volume_tags            = merge(local.interum_tags, { "Role" = count.index == 0 ? "Admin" : "Web" })
  subnet_id              = var.subnet_id # data.aws_subnets.selected.id
  user_data              = templatefile("${path.module}/template/user_data.sh.tpl", { hostname = join("", [var.base_name, "w", (count.index + 1)]) })
  vpc_security_group_ids = var.web_security_group
  key_name               = var.key_name
  iam_instance_profile   = var.web_instance_profile != "" ? var.web_instance_profile : "WebServer"
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_default
    volume_type           = "gp3"
  }

  # lifecycle {
  #   ignore_changes = all
  # }
}

resource "aws_route53_record" "webpvt" {
  count   = length(local.webserver_info)
  zone_id = var.r53_zone_id
  name    = join("", [var.base_name, "w", (count.index + 1), "pvt"])
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web[count.index].private_ip]
}
