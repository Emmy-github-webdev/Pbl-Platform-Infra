# resource "aws_wafv2_web_acl" "alb_waf" {
#   name  = "${var.tags.project}-${var.tags.environment}-alb-waf"
#   scope = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${var.tags.project}-${var.tags.environment}-alb-waf"
#     sampled_requests_enabled   = true
#   }

#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.tags.project}-${var.tags.environment}-CommonRuleSet"
#       sampled_requests_enabled   = true
#     }
#   }
# }