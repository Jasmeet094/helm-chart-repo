

resource "aws_wafv2_web_acl" "default" {
  name        = "${var.environment}WAFRule"
  description = "${var.environment} WAF Rule"
  scope       = var.scope

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.environment}AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = false
    }
  }
 rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.environment}AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = false
    }
  }
  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.environment}AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = false
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                =  "${var.environment}default"
    sampled_requests_enabled   = false
  }
}

