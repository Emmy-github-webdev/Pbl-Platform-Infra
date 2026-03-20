resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.tags.project}-${var.tags.environment}-alb-log"
}

resource "aws_lb" "app_alb" {
  name                       = "${var.tags.project}-${var.tags.environment}-app-alb"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = true
  drop_invalid_header_fields = true

    access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    enabled = true
    prefix  = "alb"
  }
  depends_on = [aws_s3_bucket_policy.lb_logs_policy]
}

resource "aws_s3_bucket_policy" "lb_logs_policy" {
  bucket = aws_s3_bucket.lb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "AWSLoadBalancerWrite",
        Effect: "Allow",
        Principal: {
          Service: "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action: "s3:PutObject",
        Resource: "${aws_s3_bucket.lb_logs.arn}/alb/*"
      },
      {
        Sid: "AWSLoadBalancerAclCheck",
        Effect: "Allow",
        Principal: {
          Service: "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action: "s3:GetBucketAcl",
        Resource: aws_s3_bucket.lb_logs.arn
      }
    ]
  })
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = aws_lb.app_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf.arn
}