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
  default     = "SS"
  type        = string
}

variable "subnet_env" {
  description = "The name of the subnet for th environment"
  default     = "ShareServices"
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

variable primary_alb_cert {
  description = "The primary ALB cert"
  default     = "*.mobilehealthconsumer.com"
  type        = string
}

variable "internal_lb" {
  description = "Whether to make the ALB internal or not."
  default     = true
  type        = bool
}