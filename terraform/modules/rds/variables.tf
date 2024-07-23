variable "identifier" {
  description = "(Required) The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier."
  type        = string
}

variable "db_subnet_group_name" {
  description = "(Required) Name of DB subnet group."
  type        = string
}

variable "parameter_group_name" {
  description = "(Required) Name of the DB parameter group to associate."
  type        = string
}

variable "security_group_ids" {
  description = "(Required) List of VPC security groups to associate."
  type        = list(string)
}

variable "instance_class" {
  description = "(Optional) The RDS instance class."
  type        = string
  default     = "db.r6i.4xlarge"
}

variable "allocated_storage" {
  description = "(Optional) The allocated storage in gibibytes."
  type        = number
  default     = 400
}

variable "storage_type" {
  description = "(Optional) standard, gp2, gp3, or io1"
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "(Optional) The amount of provisioned IOPS. Setting this implies a storage_type of io1 or gp3."
  type        = number
  default     = 12000
}

variable "availability_zone" {
  description = "(Optional) The AZ for the RDS instance."
  type        = string
  default     = "us-west-2a"
}

variable "multi_az" {
  description = "(Optional) Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "(Optional) The ARN for the KMS encryption key."
  type        = string
  default     = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
}

variable "monitoring_role_arn" {
  description = "(Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  type        = string
  default     = ""
}

variable "password" {
  description = "(Optional) Password for the master DB user. If ommitted, DB user password will be stored in Secrets Manager."
  type        = string
  default     = null
}
