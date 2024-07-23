module "wafv2" {
  providers = {
    aws = aws.us-east-1 
   }
  count  = var.create_waf_v2 ? 1 : 0
  source = "../wafv2"
  scope = "CLOUDFRONT"
  environment = var.environment
}