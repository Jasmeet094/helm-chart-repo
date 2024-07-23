variable "environment" {
  type        = string
  description = "Environment to deploy cloudfront for"
}

variable "domain_names" {
  type        = list(string)
  description = "Alternate CNAME domain name for the cloudfront CDN"
}

variable "wp_site_url" {
  type        = string
  description = "What is teh WP url"
  default     = "mobilehealthconsumer.com"
}

variable "lb_domain_name" {
  type        = string
  description = "The domain name of the ALB to use as the origin of the Cloudfront distribution"
}

variable "acm_cert_arn" {
  type        = string
  description = "ARN of the ssl cert in ACM"
}
variable "create_waf_v2" {
  description = "Should I create a WAF for you?"
  default = false
  type = bool
}
