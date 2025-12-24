# 1. Terraform & Provider Configuration
# Defines the required providers and their versions for this project.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider configuration.
# Note: When using AWS WAF with CloudFront, the resources must be provisioned 
# in the us-east-1 (N. Virginia) region as it is the global endpoint for these services.
provider "aws" {
  region = "us-east-1" 
}

# 2. S3 Bucket (Origin Storage)
# This bucket will store your static website files (HTML, CSS, JS).
resource "aws_s3_bucket" "website_bucket" {
  bucket = "cesar-secure-site-tf-2025" # IMPORTANT: S3 bucket names must be globally unique. Change this to your own name.
}

# S3 Public Access Block
# Enforces the "Block Public Access" setting to ensure the bucket is not exposed to the internet.
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. AWS WAF (Web Application Firewall)
# Implements Layer 7 security filtering to protect against common web exploits.
resource "aws_wafv2_web_acl" "main_waf" {
  name     = "perimeter-firewall-tf"
  scope    = "CLOUDFRONT" # Defined as CloudFront to enable edge protection.
  default_action {
    allow {}
  }

  # CloudWatch metrics configuration for monitoring blocked/allowed requests.
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "mainWafMetrics"
    sampled_requests_enabled   = true
  }

  # Managed Rule: AWS Core Rule Set (CRS)
  # Provides protection against OWASP Top 10 vulnerabilities (SQLi, XSS, etc.).
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "awsCommonRules"
      sampled_requests_enabled   = true
    }
  }
}

# 4. Origin Access Control (OAC)
# Creates a secure "bridge" that allows CloudFront to fetch objects from S3
# without making the S3 bucket publicly accessible.
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 5. CloudFront Distribution (Content Delivery Network)
# Configures the global distribution and links the WAF and S3 origin.
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "S3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html" # Defines the starting page of your website.

  # Default behavior for requests (Caching and Protocol policies).
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    # Enforces HTTPS by redirecting all HTTP traffic.
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Geographic restrictions (set to "none" for global access).
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Uses the default CloudFront SSL certificate (*.cloudfront.net).
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Attaches the WAF Web ACL created in section 3.
  web_acl_id = aws_wafv2_web_acl.main_waf.arn
}

# 6. S3 Bucket Policy (Secure Access Control)
# Grants CloudFront explicit permission to read objects within the S3 bucket.
# This follows the principle of least privilege.
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}