variable "environment" {
  description = "(Required) The name of the Environment"
  type        = string
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for taggable AWS resources."
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "(Required) VPC ID that RabbitMQ broker will be deployed into."
}

variable "broker_subnet_ids" {
  type        = list(string)
  description = "(Optional) List of subnet IDs to use for the RabbitMQ broker instance."
  default     = []
}

variable "instance_type" {
  type        = string
  description = "(Optional) AmazonMQ broker instance type."
  default     = "mq.m5.large"
}

variable "engine_version" {
  type        = string
  description = "(Optional) RabbitMQ engine version."
  default     = "3.9.16"
}

variable "deployment_mode" {
  type        = string
  description = "(Optional) RabbitMQ engine version."
  default     = "CLUSTER_MULTI_AZ"
}

variable "publicly_accessible" {
  type        = bool
  description = "(Optional) Whether to enable connections from outside of the VPC."
  default     = false
}

variable "console_username" {
  type        = string
  description = "(Required) RabbitMQ user console login."
}

variable "console_password" {
  type        = string
  description = "(Required) RabbitMQ user password login."
}


