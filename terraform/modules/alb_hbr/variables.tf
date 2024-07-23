variable "aws_region" {
  description = "The region this is run in"
  default     = "us-west-2"
  type        = string
}

variable "alb_logs_bucket" {
  description = "The name of the log bucket for the ALB"
  default     = "mhc-logs"
  type        = string
}

variable "env" {
  description = "The environment this is run in"
  default     = "QA"
  type        = string
}

variable "subnet_env" {
  description = "The name of the subnet for th environment"
  default     = "QA"
}

variable "idle_timeout" {
  description = "The idle timeout for the ALB"
  default     = 60
  type        = number
}

variable "sg_env" {
  description = "The name of the security group for the environment"
  default     = "QA"
  type        = string
}

variable "alb_info" {
  description = "The info for the ALB"
  default     = {}
  type        = map(any)
}

variable "default_TG" {
  description = "The name of the Target Group"
  default     = ""
  type        = string
}

variable primary_alb_cert {
  description = "The primary ALB cert"
  default     = "*.mobilehealthconsumer.com"
  type        = string
}

variable secondary_alb_cert {
  description = "The secondary ALB cert"
  default     = [] # ["*.mobhealthinternal.com"]
  type        = list(string)
}

variable r53_healthcheck_enabled {
  description = "Should we neable route53 health checks"
  default     = false
  type        = bool
}


variable "enable_deletion_protection" {
  default = true
  type = bool
}
# If enabled here, this will disable WAFv1 and create everything with Wafv2 with is a totally different module
# Changing this from true to false is the deploy mechanism
variable "create_waf_v2" {
  description = "Should I create a WAF for you?"
  default = false
  type = bool
}

variable "create_alb_metrics" {
  description = "Should I create a WAF for you?"
  default = false
  type = bool
}
variable "vpc_id"{
  type = string
  default = "vpc-0b10526e"
}