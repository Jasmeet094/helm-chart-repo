variable "web_security_group" {
  type    = list(any)
  default = []
}

variable "db_security_group" {
  type    = list(any)
  default = []
}

variable "vpc_id" {
  description = "What is the vpc id"
}

variable "subnet_name" {
  default = "QA*"
}

variable "subnet_id" {
  type = string
  default = "subnet-d7ad06b3"
  description = "Which subnet to use for the web and DB instances"
}

variable "user_data" {
  default = ""
}

variable "key_name" {
}

variable "ami_web" {
  type    = list(any)
  default = []
}
variable "ami_db" {
  type    = string
  default = ""
}

variable "eip_web" {
  type    = list(any)
  default = []
}
variable "eip_db" {
  type    = string
  default = ""
}

variable "num_of_web" {
  default = 2
}

variable "shard_type" {
  description = "What tpye of shard is this (log or s01 or s0x)"
  type        = string
}

variable "base_name" {
  type        = string
  description = "What is teh base name of the env"
}

variable "r53_zone_id" {
  default = "Z2IX59JMXPQ6BD"
}

variable "shard" {
  type        = string
  description = "What shard is this"
}

variable "create_secondary_volumes" {
  type        = bool
  description = "Should we create secondary volumes for the ec2 instances"
  default     = false
}

variable "create_eips" {
  type        = bool
  description = "should we create new EIPS"
  default     = true
}

variable "db_instance_type" {
  type        = string
  description = "What instance size should the db server be?"
  default     = "t3.large"
}

variable "web_instance_type" {
  type        = string
  description = "What instance size should the db server be?"
  default     = "t3.large"
}

variable "kms_anthem" {
  type    = string
  default = "arn:aws:kms:us-west-2:950511364051:key/24b9d676-6806-40db-a695-15b89f058712"
}
variable "kms_default" {
  type    = string
  default = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
}
variable "shards_anthem" {
  type    = list(string)
  default = [""]
}

variable "web_instance_profile" {
  type        = string
  description = "IAM Instance Profile to launch Web instances with. Specified as the name of the Instance Profile."
  default     = ""
}

variable "db_instance_profile" {
  type        = string
  description = "IAM Instance Profile to launch DB instances with. Specified as the name of the Instance Profile."
  default     = ""
}
