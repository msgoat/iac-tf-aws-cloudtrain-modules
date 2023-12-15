variable "region_name" {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
}

variable "solution_name" {
  description = "The name of the solution that owns all AWS resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current environment stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the solution (i.e. solution_name + solution_stage in most cases)."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all AWS resources."
  type        = map(string)
}


variable "create_origin_access_control" {
  description = "Controls if CloudFront origin access control should be created"
  type        = bool
  default     = false
}

variable "origin_access_control" {
  description = "Map of CloudFront origin access control"
  type        = map(object({
    description      = string
    origin_type      = string
    signing_behavior = string
    signing_protocol = string
  }))

  default = {
    s3 = {
      description      = "Origin Description",
      origin_type      = "s3",
      signing_behavior = "always",
      signing_protocol = "sigv4"
    }
  }
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
  default     = null
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

variable "web_acl_id" {
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = null
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "The name of the buckets regional domain name"
}

variable "s3_bucket_id" {
  type        = string
  description = "The id of the s3 bucket to connect the distribution to"
}

variable "cloudfront_access_identity_path" {
  type        = string
  description = "Access identity path used for cloudfront s3 origin config"
}

variable "acm_certificate_arn" {
  description = "The arn of the certificate used for the cloudfront distribution"
  type        = string
}

variable "geo_restriction" {
  description = "The restriction configuration for this distribution (geo_restrictions)"
  type        = object({
    restriction_type = string
    locations        = list(string)
  })
  default = null
}

variable "logging_config" {
  description = "The logging configuration that controls how logs are written to your distribution."
  type        = object({
    bucket_name     = string
    prefix          = string
    include_cookies = bool
  })
}

variable "target_origin_id" {
  description = "Value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior"
  type        = string
}

variable "origin_request_policy_id" {
  description = "Unique identifier of the origin request policy that is attached to the behavior."
  type        = string
}

variable "cache_policy_id" {
  description = "Unique identifier of the cache policy that is attached to the cache behavior."
  type        = string
}

variable "create_monitoring_subscription" {
  description = "If enabled, the resource for monitoring subscription will created."
  type        = bool
  default     = false
}

variable "realtime_metrics_subscription_status" {
  description = "A flag that indicates whether additional CloudWatch metrics are enabled for a given CloudFront distribution. Valid values are `Enabled` and `Disabled`."
  type        = string
  default     = "Enabled"
}

