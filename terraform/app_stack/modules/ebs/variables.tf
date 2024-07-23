variable "device_path" {
  default = "/dev/sdf"
}

variable "region" {
  default = "us-west-2"
}

variable "app_env" {}
variable "shard" {}
variable "server" {}
variable "instance_id" {}
variable "az" {}
variable "size" {}
variable "kms_key_id" {
  # anthem  default = "arn:aws:kms:us-west-2:950511364051:key/24b9d676-6806-40db-a695-15b89f058712"
}
variable "tags" {
  type        = "map(string)"
  description = "tags for ebs volumes"
}
