#!/bin/bash

####################################################################################################
# Checkov Report Parser with Markdown Tables & color-coded Output
#
# This script processes checkov scan output and generates:
# - Markdown-formated compliance scorecard (at a glance view)
# - Checks grouped by AWS service in markdown tables
# - Detailed pass/fail reporting with color-coding
#
# Usage: ./parse-checkov-report.sh [report-file] [output-file]
####################################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Variables
REPORT_FILE="${1:-/tmp/checkov-output.txt}"
OUTPUT_FILE="${2:-checkov-report-parsed.txt}"
MARKDOWN_FILE="${OUTPUT_FILE%.txt}-markdown.md"
PASSED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

# TEMPORARY FILES FOR ORGANIZING RESULTS
TEMP_DIR="/tmp/checkov-parse-$$"
mkdir -p "$TEMP_DIR"
trap "rm -rf $TEMP_DIR" EXIT

####################################################################
# Function:  Extract metrics from Checkov output
####################################################################
extract_metrics() {
    echo ""Extracting metrics from Checkov report..."" >&2

# macOS compatible regex extraction (no -p flag)
    PASSED_COUNT=$(grep -oP '(?<=Passed checks: )\d+' "$REPORT_FILE" | sed -E 's/.*Passed checks:[ ]([0-9]+).*/\1/' || head -1)
    FAILED_COUNT=$(grep -oP '(?<=Failed checks: )\d+' "$REPORT_FILE" | sed -E 's/.*Failed checks:[ ]([0-9]+).*/\1/' || head -1)
    SKIPPED_COUNT=$(grep -oP '(?<=Skipped checks: )\d+' "$REPORT_FILE" | sed -E 's/.*Skipped checks:[ ]([0-9]+).*/\1/' || head -1)

    # Fallback to 0 if not found
    PASSED_COUNT=${PASSED_COUNT:-0}
    FAILED_COUNT=${FAILED_COUNT:-0}
    SKIPPED_COUNT=${SKIPPED_COUNT:-0}

    echo "✓ Passed: ${PASSED_COUNT} | ❌ Failed: ${FAILED_COUNT} | Ø Skipped: ${SKIPPED_COUNT}" >&2
}

####################################################################
# Function: Extract and organize checks by service
####################################################################
organize_by_service() {
    echo "🔍 Organizing checks by AWS service..." >&2

    local temp_passed="$TEMP_DIR/all_passed.txt"
    local temp_failed="$TEMP_DIR/all_failed.txt"
    local temp_skipped="$TEMP_DIR/all_skipped.txt"

    # Extract all checks to temporary files first
    grep -E "^\[PASS\]" "$REPORT_FILE" > "$temp_passed" 2> /dev/null || touch "$temp_passed"
    grep -E "^\[FAIL\]" "$REPORT_FILE" > "$temp_failed" 2> /dev/null || touch "$temp_failed"
    grep -E "^\[SKIP\]" "$REPORT_FILE" > "$temp_skipped" 2> /dev/null || touch "$temp_skipped"

    # Process passed checks
    if [[ -s "$temp_passed" ]]; then
        while IFS= read -r line; do
            CHECK_ID=$(echo "$line" | grep -oE 'CKV[A-Z]*_[0-9]+' | head -1)
            SERVICE=$(extract_service_from_check "$line") || SERVICE="Other"
            if [ -n "$SERVICE" ] && [ -n "$CHECK_ID" ]; then
                SERVICE_FILE="$TEMP_DIR/passed_${SERVICE}.txt"
                echo "$CHECK_ID|$line" >> "$SERVICE_FILE"2> /dev/null || true
            fi
        done < "$temp_passed" || return 1
    fi

    # process failed checks
    if [[ -s "$temp_failed" ]]; then
        while IFS= read -r line; do
            CHECK_ID=$(echo "$line" | grep -oE 'CKV[A-Z]*_[0-9]+' | head -1)
            SERVICE=$(extract_service_from_check "$line") || SERVICE="Other"
            if [ -n "$SERVICE" ] && [ -n "$CHECK_ID" ]; then
                SERVICE_FILE="$TEMP_DIR/failed_${SERVICE}.txt"
                echo "$CHECK_ID|$line" >> "$SERVICE_FILE" 2> /dev/null || true
            fi
        done < "$temp_failed" || return 1
    fi

    # Process skipped checks
    if [[ -s "$temp_skipped" ]]; then
        while IFS= read -r line; do
            CHECK_ID=$(echo "$line" | grep -oE 'CKV[A-Z]*_[0-9]+' | head -1)
            SERVICE=$(extract_service_from_check "$line") || SERVICE="Other"
            if [ -n "$SERVICE" ] && [ -n "$CHECK_ID" ]; then
                SERVICE_FILE="$TEMP_DIR/skipped_${SERVICE}.txt"
                echo "$CHECK_ID|$line" >> "$SERVICE_FILE" 2> /dev/null || true
            fi
        done < "$temp_skipped" || return 1
    fi

    # Clean up temporary files
    rm -f "$temp_passed" "$temp_failed" "$temp_skipped" 2> /dev/null || true

    return 0
}

####################################################################
# Function: Extract AWS service from the check line
####################################################################

extract_service_from_check() {
    local check_line="$1" 
    local service="General" # Default fallback

    # try to extract from resource type first (most reliable)
    if echo "$line" | grep -qiE "aws_dynamo|dynamodb|table"; then
        service="DynamoDB"
    elif echo "$line" | grep -qiE "aws_s3|s3.*bucket"; then
        service="S3"
    elif echo "$line" | grep -qiE "aws_lambda|lambda"; then
        service="Lambda"
    elif echo "$line" | grep -qiE "aws_iam|iam"; then
        service="IAM"
    elif echo "$line" | grep -qiE "aws_ec2|ec2"; then
        service="EC2"
    elif echo "$line" | grep -qiE "aws_rds|rds"; then
        service="RDS"
    elif echo "$line" | grep -qiE "aws_sqs|sqs"; then
        service="SQS"
    elif echo "$line" | grep -qiE "aws_sns|sns"; then
        service="SNS"
    elif echo "$line" | grep -qiE "aws_eks|eks"; then
        service="EKS"
    elif echo "$line" | grep -qiE "aws_vpc|vpc"; then
        service="VPC"
    elif echo "$line" | grep -qiE "aws_apigateway|apigateway"; then
        service="API Gateway"
    elif echo "$line" | grep -qiE "aws_kms|kms"; then
        service="KMS"
    elif echo "$line" | grep -qiE "aws_cloudfront|cloudfront"; then
        service="CloudFront"
    elif echo "$line" | grep -qiE "aws_cloudwatch|cloudwatch"; then
        service="CloudWatch"
    elif echo "$line" | grep -qiE "aws_route53|route53"; then
        service="Route 53"
    elif echo "$line" | grep -qiE "aws_elb|elb|load_balancer"; then
        service="ELB"
    elif echo "$line" | grep -qiE "aws_autoscaling|autoscaling"; then
        service="Auto Scaling"
    elif echo "$line" | grep -qiE "aws_cloudtrail|cloudtrail"; then
        service="CloudTrail"
    elif echo "$line" | grep -qiE "aws_elasticsearch|elasticsearch"; then
        service="Elasticsearch"
    fi
    echo "$service"
}

####################################################################
# Function: Calculate compliance percentage
####################################################################
Calculate_compliance() {
    local total=$((PASSED_COUNT + FAILED_COUNT ))
    if [ "$total" -eq 0 ]; then
        echo "0"
    else
        echo $((PASSED_COUNT * 100 / total))
    fi
}

####################################################################
# Function: get markdown color based on compliance score
####################################################################
get_badge_markdown() {
    local score=$1
    if [ "$score" -ge 90 ]; then
        echo "![Compliance](https://img.shields.io/badge/compliance-$(score)%25-green)"
    elif [ "$score" -ge 70 ]; then
        echo "![Compliance](https://img.shields.io/badge/compliance-$(score)%25-yellow)"
    else
        echo "![Compliance](https://img.shields.io/badge/compliance-$(score)%25-red)"
    fi
}

####################################################################
# Function: Print markdown compliance scorecard
####################################################################
