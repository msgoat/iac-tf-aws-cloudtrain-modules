resource "aws_cloudfront_origin_access_control" "cdn" {
  for_each = local.create_origin_access_control ? var.origin_access_control : {}

  name = each.key

  description                       = each.value["description"]
  origin_access_control_origin_type = each.value["origin_type"]
  signing_behavior                  = each.value["signing_behavior"]
  signing_protocol                  = each.value["signing_protocol"]
}

resource "aws_cloudfront_distribution" "cdn" {
  aliases             = var.aliases
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id
  tags                = merge(var.tags, local.module_common_tags)

  logging_config {
    bucket          = var.logging_config.bucket_name
    prefix          = var.logging_config.prefix
    include_cookies = var.logging_config.include_cookies
  }

  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = var.s3_bucket_id

    s3_origin_config {
      origin_access_identity = var.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.target_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    origin_request_policy_id = var.origin_request_policy_id
    cache_policy_id          = var.cache_policy_id

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # If there is a 400, return index.html with a HTTP 200 Response to let SPA handle it
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 400
    response_code         = 200
    response_page_path    = "/index.html"
  }

  # If there is a 403, return index.html with a HTTP 200 Response to let SPA handle it
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  # If there is a 404, return index.html with a HTTP 200 Response to let SPA handle it
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn

    minimum_protocol_version = "TLSv1.2"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.geo_restriction]

      content {
        restriction_type = geo_restriction.value.restriction_type
        locations        = geo_restriction.value.locations
      }
    }
  }
}

resource "aws_cloudfront_monitoring_subscription" "cdn" {
  count = var.create_monitoring_subscription ? 1 : 0

  distribution_id = aws_cloudfront_distribution.cdn.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = var.realtime_metrics_subscription_status
    }
  }
}