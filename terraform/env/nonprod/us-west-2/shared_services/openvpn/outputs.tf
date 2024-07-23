output "OpenVPN_EIP" {
  value = "${module.aws_openvpn.OpenVPN_EIP}"
}

output "OpenVPN_Admin_Username" {
  value = "openvpn"
}

output "OpenVPN_Admin_Password" {
  value = "${module.aws_openvpn.OpenVPN_Admin_Password}"
}
