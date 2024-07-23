data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"
}

locals {
  database_server      = "${var.server == "db1" ? "Database" : ""}"
  admin_server         = "${var.server == "w1" ? "Admin" : ""}"
  web_server           = "${var.server == "w2" ? "Web" : ""}"
}