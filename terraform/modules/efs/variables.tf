variable "efs_kms" {
  description = "Primart region kms ks"
  type        = string
}

variable "env" {
  description = "ENV"
  type        = string
}
variable "subnets" {
  description = "what are the tgs"
  type        = list(string)
}
variable "vpc_id" {
  description = "vpc_id"
  type        = string
}
variable "r53_hosted_zone" {
  description = "r53 hosted_zone"
  type        = string
}
