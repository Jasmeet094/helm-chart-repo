variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for taggable AWS resources."
  default     = {}
}

variable "environment" {
  type        = string
  description = "(Required) The name of the environment."
}

variable "vpc_id" {
  type        = string
  description = "(Required) VPC ID that RabbitMQ broker will be deployed into."
}

variable "description" {
  description = "(Required) User-created description for the replication group."
  type        = string
}

variable "replication_group_id" {
  description = "(Required) Replication group identifier. This parameter is stored as a lowercase string."
  type        = string
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "(Optional) Specifies whether minor version engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window."
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "(Optional) Whether to enable encryption at rest."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "What KMS key to use"
  type        = string
  default     = null
}

variable "preferred_cache_cluster_azs" {
  description = "(Optional) List of EC2 availability zones in which the replication group's cache clusters will be created."
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "(Optional) Version number of the cache engine to be used for the cache clusters in this replication group."
  type        = string
  default     = "6.x"
}

variable "node_type" {
  description = "(Optional) Instance class to be used."
  type        = string
  default     = "cache.m5.large"
}

variable "parameter_group_name" {
  description = "(Required unless replication_group_id is provided) The name of the parameter group to associate with this cache cluster."
  type        = string
  default     = "default.redis6.x"
}

variable "num_node_groups" {
  description = "(Optional) Number of node groups (shards) for this Redis replication group."
  type        = number
  default     = 1
}

variable "replicas_per_node_group" {
  description = "(Optional) Number of replica nodes in each node group. Valid values are 0 to 5."
  type        = number
  default     = 1
}

variable "redis_subnet_ids" {
  description = "List of subnet IDs to use for Redis Subnet Group. Private subnets is the best practice."
  type        = list(string)
}
