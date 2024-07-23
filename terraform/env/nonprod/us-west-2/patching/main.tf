provider "aws" {
  region = var.region
}

module "patching" {
  source = "../../../../modules/auto_patching"

  patch_group = "ofog-2204-test"
}
