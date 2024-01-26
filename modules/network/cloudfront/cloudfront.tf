resource "aws_cloudfront_origin_access_control" "cdn" {
  for_each = local.create_origin_access_control ? var.origin_access_control : {}

  name = each.key

  description                       = each.value["description"]
  origin_access_control_origin_type = each.value["origin_type"]
  signing_behavior                  = each.value["signing_behavior"]
  signing_protocol                  = each.value["signing_protocol"]
}

data "aws_cloudfront_cache_policy" "managed_cachingoptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "managed_cors_s3origin" {
  name = "Managed-CORS-S3Origin"
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

  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []

    content {
      bucket          = var.logging_config.bucket_name
      prefix          = var.logging_config.prefix
      include_cookies = var.logging_config.include_cookies
    }
  }

  origin {
    domain_name = var.origin.domain_name
    origin_id   = var.origin.origin_id

    s3_origin_config {
      origin_access_identity = var.origin.origin_access_identity
    }
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.origin.origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_cors_s3origin.id
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_cachingoptimized.id

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
    cloudfront_default_certificate = var.acm_certificate_arn != null
    acm_certificate_arn            = var.acm_certificate_arn != null ? var.acm_certificate_arn : null

    minimum_protocol_version = var.acm_certificate_arn != null ? "TLSv1.2" : null
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