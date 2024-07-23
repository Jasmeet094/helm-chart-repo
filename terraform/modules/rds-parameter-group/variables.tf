variable "name" {
  description = "(Required, Forces new resource) The name of the DB parameter group."
  type        = string
}

variable "description" {
  description = "(Optional, Forces new resource) The description of the DB parameter group."
  type        = string
  default     = "Managed by Terraform"
}

variable "parameters" {
  description = "A list of DB parameters to apply."
  type = list(object({
    name         = string
    value        = any
    apply_method = string
  }))
}
