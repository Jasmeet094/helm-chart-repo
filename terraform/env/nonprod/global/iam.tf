module "aws_iam" {
  source = "git@github.com:FoghornConsulting/m-iam"

  force_mfa              = true
  modify_security_groups = true
  deny_terminate         = false
  use_cloudhealth        = true
  cloudhealth_ext_id     = "af87b2e3a80887021b2e68cd0a0028"
  administrators         = ["taylor@foghornconsulting.com", "george"]
}
