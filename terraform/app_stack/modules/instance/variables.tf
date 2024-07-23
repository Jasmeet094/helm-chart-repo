variable "az" {}
variable "server" {}
variable "shard" {}
variable "profile" {}
variable "subnet" {}
variable "key" {}
variable "domain" {}
variable "r53_zone_id" {}
variable "r53_private_zone_id" {}
variable "env" {}
variable "kms_key_id" {
   default = "arn:aws:kms:us-west-2:950511364051:key/24b9d676-6806-40db-a695-15b89f058712" # anthem 
}

variable "eip" {
  default = ""
}

variable "security_group_ids" {
  type = "list(string)"
}

variable "tag_operations" {
  default = ""
  /* "{\"HIPAA\": \"T\"}" -- only for Production */
}

variable "user_data" {
  default = ""
}

variable "instance_type" {
  default = "t3.small"
}

variable "root_volume_size" {
  default = "20"
}

variable "ami" {}
