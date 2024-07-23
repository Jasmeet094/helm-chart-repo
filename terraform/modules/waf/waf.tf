/*
/partners/partner/updateIncentive/
/partners/partner/updateMessage/
/partners/partner/updateResource/
/partners/partner/clients/
*/

resource "aws_wafregional_rule" "non_partners_paths" {
  name        = "${var.waf_name}_base-path-xss"
  metric_name = "${replace(var.waf_name, "-", "")}BasePathRule"

  predicate {
    data_id = "${aws_wafregional_xss_match_set.xss_match_set.id}"
    negated = false
    type    = "XssMatch"
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_wafregional_xss_match_set" "xss_match_set" {
  name = "${var.waf_name}_xss_match_set"

  xss_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "BODY"
    }
  }

  # xss_match_tuple {
  #   text_transformation = "NONE"
  #   field_to_match {
  #     type = "BODY"
  #   }
  # }

  xss_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_wafregional_byte_match_set" "partners_configure_uris" {
  name = "${var.waf_name}_partners_configure_uris"

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/configureResource/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partners/configureEmail/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partners/configureIncentive/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partners/configureMessage/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partners/configureReimbursementPlan/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partners/configureClientCareGap/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/configureSection/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_byte_match_set" "partners_update_uris" {
  name = "${var.waf_name}_partners_update_uris"

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/updateIncentive/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/updateMessage/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/updateResource/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/clients/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/configureTile/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuple {
    text_transformation   = "NONE"
    target_string         = "/partners/partner/getChallengeCourseInfo/"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_rule" "partners_uri_update_xss" {
  name        = "${var.waf_name}_partners-uri-update-xss"
  metric_name = "${replace(var.waf_name, "-", "")}PartnersUriUpdateXSS"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.partners_update_uris.id}"
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = "${aws_wafregional_xss_match_set.xss_match_set.id}"
    negated = false
    type    = "XssMatch"
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_wafregional_rule" "partners_uri_config_xss" {
  name        = "${var.waf_name}_partners-uri-config-xss"
  metric_name = "${replace(var.waf_name, "-", "")}PartnersUriConfigXSS"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.partners_configure_uris.id}"
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = "${aws_wafregional_xss_match_set.xss_match_set.id}"
    negated = false
    type    = "XssMatch"
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_wafregional_web_acl" "waf_acl" {
  name        = "${var.waf_name}"
  metric_name = "${replace(var.waf_name, "-", "")}"

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "ALLOW"
    }
    priority = 1
    rule_id  = "${aws_wafregional_rule.partners_uri_config_xss.id}"
  }

  rule {
    action {
      type = "ALLOW"
    }
    priority = 2
    rule_id  = "${aws_wafregional_rule.partners_uri_update_xss.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }
    priority = 3
    rule_id  = "${aws_wafregional_rule.non_partners_paths.id}"
  }
}

resource "aws_wafregional_web_acl_association" "default" {
  resource_arn = "${var.lb_arn}"
  web_acl_id   = "${aws_wafregional_web_acl.waf_acl.id}"
}
