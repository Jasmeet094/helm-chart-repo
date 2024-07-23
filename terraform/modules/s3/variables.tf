variable "bucket_name" {
  description = "(Required) The name of the s3 bucket."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags for the S3 bucket."
  default     = {}
}
