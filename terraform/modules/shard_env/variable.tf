variable "environment" {
  description = "What environment is this"
}

variable "vpc_id" {
  description = "What is the vpc id"
}

variable "subnet_name" {
  default = "QA*"
}
variable "efs_kms" {
  description = "Primart region kms ks"
  type        = string
  default     = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
}

variable "r53_hosted_zone" {
  description = "r53 hosted_zone"
  type        = string
  default     = "Z2IX59JMXPQ6BD"
}

variable "enable_internet" {
  description = "Do you want to enable internet"
  type        = bool
  default     = true
}

variable "enable_efs" {
  description = "Do you want to enable efs"
  type        = bool
  default     = false
}

variable "monitoring_sg_id" {
  type = string
  default = "sg-e2d24086"
  description = "ID of Nagios server security group. Set to \"\" (empty string) if not using."
}