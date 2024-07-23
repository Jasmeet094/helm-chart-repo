variable "subdomain" {}
variable "lb_arn" {}

variable "additional_aliases" {
  type        = "list(string)"
  default     = []
  description = "Additional subdomains (of the same var.root_domain) to alias to the new Cloudfront distribution"
}

variable "logging_bucket" {
  default = "mhc.wafs"
}

variable "root_domain" {
  default = "mobilehealthconsumer.com"
}

variable "zone_id" { default = "" }

variable "acm_cert_arn" {
  default = "arn:aws:acm:us-east-1:913835907225:certificate/64ea62e7-5e6c-4c8c-a9d8-015c241df83c"
}

variable "cost_center" {
  default = ""
}

variable "logging_prefix" {
  default = ""
}

variable "price_class" {
  default = "PriceClass_All"
}

variable "environment" {
  default = "dev"
}

variable "waf_name" {
  default = "tf-acl-test"
}

variable "viewer_protocol_policy" {
  default = "redirect-to-https"
}
