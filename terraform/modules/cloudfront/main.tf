locals {
  behavior_paths = ["/partners/*", "/partners", "/static/*", "/media/*", "/web/*", "/weba/*", "/api/*", "/eapi/*", "/sentry/*", "/appImages/*", "/ClientContentPages/*", "/ContentImages/*", "/css/*", "/dmo/*", "/DowntimePage/*", "/fonts/*", "/images/*", "/img/*", "/Jan16/*", "/javascripts/*", "/js/*", "/libs/*", "/monthlyFeature/*", "/r2w_backup/*", "/SAML2/*", "/stylesheets/*", "/videos/*", "/privacy.html", "/tos.html", "/favicon.ico", "/.well-known/*", "/apple-app-site-association", "/mhc-icon.png", "/studenthealth.html", "/studenthealth", "/reset/confirm/*", "/privacy-policy/*"]
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    origin_id   = "site_lb"
    domain_name = var.lb_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  origin {
    origin_id   = "wp_site"
    domain_name = var.wp_site_url
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  # default_root_object = "index.php"
  logging_config {
    include_cookies = false
    bucket          = "mhc-logs.s3.amazonaws.com"
    prefix          = "${lower(var.environment)}/AWSLogs/${data.aws_caller_identity.current.account_id}/CloudFront/"
  }

  aliases = var.domain_names

  dynamic "ordered_cache_behavior" {
    for_each = local.behavior_paths
    content {
      path_pattern     = ordered_cache_behavior.value
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "site_lb"

      forwarded_values {
        query_string = true
        headers      = ["*"]

        cookies {
          forward = "all"
        }
      }

      min_ttl                = 0
      default_ttl            = 0
      max_ttl                = 0
      viewer_protocol_policy = "redirect-to-https"
    }
  }


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "wp_site"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    # lambda_function_association {
    #   event_type   = "viewer-request"
    #   lambda_arn   = aws_lambda_function.lambda_edge.qualified_arn
    #   include_body = false
    # }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.create_waf_v2 ? module.wafv2[0].web_acl.arn: null

  # tags = {
  #   Environment = lower(var.environment) == "production" ? "p" : lower(var.environment)
  # }
}
