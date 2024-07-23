variable "tags" {
  description = "A map of tags to be added to associated resources"
  type        = map(string)

  default = {
    Terraform = true
  }
}

variable "patch_filters" {
  description = "List of patch filters used for approval rules"
  type = list(object({
    key    = string
    values = list(string)
  }))
  default = [
    {
      key    = "PRODUCT"
      values = ["Ubuntu22.04"]
    },
    {
      key    = "SECTION"
      values = ["*"]
    },
    {
      key    = "PRIORITY"
      values = ["*"]
    }
  ]
}

variable "sources" {
  description = "List of Ubuntu 22.04 base repos"
  type = list(object({
    name          = string
    products      = list(string)
    configuration = string
  }))
  default = [
    {
      name          = "ubuntu-main"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ jammy main restricted"
    },
    {
      name          = "ubuntu-updates-main"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ jammy-updates main restricted"
    },
    {
      name          = "ubuntu-universe"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ jammy universe"
    },
    {
      name          = "ubuntu-updates-universe"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ jammy-updates universe"
    },
    {
      name          = "ubuntu-multiverse"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ jammy multiverse"
    },
    {
      name          = "ubuntu-updates-multiverse"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ jammy-updates multiverse"
    },
    {
      name          = "ubuntu-backports-main"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse"
    },
    {
      name          = "ubuntu-security-main"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://security.ubuntu.com/ubuntu jammy-security main restricted"
    },
    {
      name          = "ubuntu-security-universe"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://security.ubuntu.com/ubuntu jammy-security universe"
    },
    {
      name          = "ubuntu-security-multiverse"
      products      = ["Ubuntu22.04"]
      configuration = "deb http://security.ubuntu.com/ubuntu jammy-security multiverse"
    }
  ]
}

variable "patch_group" {
  description = "Tag value used to target instances for patching."
  type        = string
}