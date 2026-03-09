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
print_markdown_scorecard() {
    local compliance_score=$(Calculate_compliance)
    local badge=$(get_badge_markdown "$compliance_score")

    {
        echo ""
        echo "# Checkov Security Scan Report"
        echo ""
        echo "$badge"
        echo ""
        echo "## Compliance Scorecard (At-A-Glance)"
        echo ""
        echo "| Metric | Count | Status |"
        echo "|--------|-------|-------|"
        printf "| ✅ Passed Checks | %d | ![Pass](https://img.shields.io/badge/status-passed-green) |\n" "$PASSED_COUNT"
        printf "| ❌ Failed Checks | %d | ![Fail](https://img.shields.io/badge/status-failed-red) |\n" "$FAILED_COUNT"
        printf "| Ø Skipped Checks | %d | ![Skipped](https://img.shields.io/badge/status-skipped-yellow) |\n" "$SKIPPED_COUNT"
        echo ""
        echo "**Overall Compliance score: ${compliance_score}%**"
        echo ""

        if [ "$compliance_score" -ge 90 ]; then
            echo "> ✅ **EXCELLENT** - Infrastructure meets security best practices. Keep up the great work! 🎉"
        elif [ "$compliance_score" -ge 70 ]; then
            echo "> ⚠️ **GOOD** - Most security controls in place; Focus on addressing the failed checks to boost your compliance score. 💪"
        else
            echo "> 🚫 **CRITICAL** - Major security compliance issue; Prioritize fixing the failed checks to enhance your security posture. 🚨"
        fi
        echo ""
    } | tee -a "$MARKDOWN_FILE"

}

####################################################################
# Function: Print markdown checks grouped by service
####################################################################
print_markdown_grouped_results() {
  {
        echo ""
    echo "## Security Checks by AWS Service"
    echo ""

    # get list of services sorted
    local services=$(ls "$TEMP_DIR"/PASSED_*.TXT "${TEMP_DIR}"/failed_*.txt "${TEMP_DIR}"/skipped_*.txt 2> /dev/null | \
              sed 's/.*_//; s/.txt$//' | sort -u)
    
    for service in $services; do
        print_markdown_service_section "$service"
    done
  } | tee -a "$MARKDOWN_FILE"

}

####################################################################
# Function: Print markdown results for a single service
####################################################################
print_markdown_service_section() {
    local service=$1
    local passed_file="$TEMP_DIR/passed_${service}.txt"
    local failed_file="$TEMP_DIR/failed_${service}.txt"
    local skipped_file="$TEMP_DIR/skipped_${service}.txt"

    local passed_count=0
    local failed_count=0    
    local skipped_count=0

    [ -f "$passed_file" ] && passed_count=$(wc -l < "$passed_file")
    [ -f "$failed_file" ] && failed_count=$(wc -l < "$failed_file")
    [ -f "$skipped_file" ] && skipped_count=$(wc -l < "$skipped_file")

    # Skip services with no checks
    if [ "$((passed_count + failed_count + skipped_count))" -eq 0 ]; then
        return
    fi

    {
        echo ""
        echo "### $service"
        echo ""

        # Summary table
        echo "| Status | Count |"
        echo "|--------|-------|"
        printf "| ✅ Passed Checks | %d |\n" "$passed_count"
        printf "| ❌ Failed Checks | %d |\n" "$failed_count"
        printf "| Ø Skipped Checks | %d |\n" "$skipped_count"
        echo ""

        # PASSED checks table
        if [ "$passed_count" -gt 0 ]; then
            echo "#### ✅ Passed Checks"
            echo ""
            echo "| Check ID | Description |"
            echo "|----------|-------------|"
            if [ -f "$passed_file" ]; then
                sort "$passed_file" | while IFS='|' read -r check_id description; do
                    check_name=$(echo "$line" |  sed 's/.*\[PASSED\] //; s/ \[.*//')
                    printf "| %s | %s |\n" "$check_id" "$check_name"
                done
            fi
            echo ""
        fi

        # FAILED checks table
        if [ "$failed_count" -gt 0 ]; then
            echo "#### ❌ Failed Checks ($filed_count)"
            echo "| Check ID | Description | Resource |"
            echo "|----------|-------------|----------|"
            if [ -f "$failed_file" ]; then
                sort "$failed_file" | while IFS='|' read -r check_id line; do
                    check_name=$(echo "$line" |  sed 's/.*\[FAILED\] //; s/ \[.*//')
                    resource=$(echo "$line" | grep -oP 'resource: \K[^ ]+' || echo "N/A")
                    printf "| %s | %s | %s |\n" "$check_id" "$check_name" "$resource"
                done
            fi
            echo ""
        fi

        # SKIPPED checks table
        if [ "$skipped_count" -gt 0 ]; then
            echo "#### Ø Skipped Checks ($skipped_count)"
            echo "| Check ID | Description |"
            echo "|----------|-------------|"
            if [ -f "$skipped_file" ]; then
                sort "$skipped_file" | while IFS='|' read -r check_id line; do
                    check_name=$(echo "$line" |  sed 's/.*\[SKIPPED\] //; s/ \[.*//')
                    printf "| %s | %s |\n" "$check_id" "$check_name"
                done
            fi
            echo ""
        fi
    } | tee -a "$MARKDOWN_FILE"
}

####################################################################
# Function: Print markdown recommendations
####################################################################
print_markdown_recommendations() {
    {
        echo ""
        echo "## 💡 Recommendations"
        echo ""

        local compliance_score=$(Calculate_compliance)
        if [ "$compliance_score" -ge 90 ]; then
            echo "### ✅ Excellent Compliance"
            echo ""
            echo "Your infrastructure meets security best practices. Continue maintaining"
            echo "these standards in future deployments."
        elif [ "$compliance_score" -ge 70 ]; then
            echo "### ⚠️ Good Compliance with Improvement Needed"
            echo ""
            echo "Most security controls are in place. Address the failed checks below"
            echo "before production deployment."
            echo ""
        else
            echo "### 🚫 Critical Compliance Issues"
            echo ""
            echo "***DO NOT PROCEED TO PRODUCTION.** Major security compliance issues"
            echo "must be addressed immediately. See failed checks below."
            echo ""
        fi

        if ["$FAILED_COUNT" -gt 0 ]; then
            echo "### Priority Failed Checks"
            echo ""
            echo "| Check ID | Resource | Description |"
            echo "|----------|----------|-------------|"
            grep "^\[failed\]" "$REPORT_FILE" | sort -u | head -10 | while IFS= read -r line; do
                check_id=$(echo "$line" | grep -oP 'CKV[A-Z]*_[0-9]*_\d+' | head -1)
                resource=$(echo "$line" | grep -oP 'resource: \K[^ ]+' || echo "N/A")
                check_name=$(echo "$line" |  sed 's/.*\[FAILED\] //; s/ \[.*//')
                description=$(echo "$line" | sed 's/.*\[FAILED\] //; s/ \[.*//')
                printf "| %s | %s | %s |\n" "$check_id" "$resource" "$check_name"
            done
            
            if [ "$FAILED_COUNT" -gt 10 ]; then
                echo "| ... | ... | ... and $((FAILED_COUNT - 10)) more failed checks ...|"
            fi
            echo ""
        fi

        echo "### next Steps"
        echo ""
        echo "1. **review failed Checks**: Understand each failing check's requirements"
        echo "2. **Remediate Issues**: Update terraform configurations as needed"
        echo "3. **Re-scan**: run Checkov again to verify fixes"
        echo "4. **Document Exceptions**: For any acceptance non-compliance, document the business justification."
        echo ""
        echo "For detailed Checkov documentation, visit https://www.checkov.io/"

    } | tee -a "$MARKDOWN_FILE"
}

####################################################################
# Function: Export metrics for GitHub Actions
####################################################################
export_metrics(){
    local compliance_score=$(Calculate_compliance)

    if [-n "${GITHUB_OUTPUT:-}" ]; then
        {
            echo "compliance_score=${compliance_score}"
            echo "passed=${PASSED_COUNT}"
            echo "failed=${FAILED_COUNT}"
            echo "skipped=${SKIPPED_COUNT}"
        } >> "${GITHUB_OUTPUT}"

        echo "✓ Metrics exported to GitHub outputs" >&2
    fi
}

####################################################################
# Main execution
####################################################################
main(){
    # clear output files
    > "$OUTPUT_FILE"
    > "$MARKDOWN_FILE"

    # Check if report files exists
    if [ ! -f "$REPORT_FILE" ]; then
        echo "❌ Checkov report file not found: $REPORT_FILE${NC}" >&2
        exit 1
    fi

    echo -e "${CYAN}=======================================================================${NC}" >&2
    echo -e "${CYAN}|| 🔒 CHECKOV SECURITY SCAN REPORT ANALYZER                          ||${NC}" >&2
    echo -e "${CYAN}=======================================================================${NC}" >&2
    echo "" >&2

    # Extraxt and process
    extract_metrics || {echo "❌ Failed to extract metrics " >&2; exit 1;}
    organize_by_service || {echo "❌ Failed to organize checks by service" >&2; exit 1;}

    # Generate markdown output
    print_markdown_scorecard || {echo "❌ Failed to generate markdown scorecard" >&2; exit 1;}
    print_markdown_grouped_results || {echo "❌ Failed to generate markdown grouped results" >&2; exit 1;}
    print_markdown_recommendations || {echo "❌ Failed to generate markdown recommendations" >&2; exit 1;}

    # export metrics
    export_metrics || {echo "⚠️ Warning: Failed to export metrics to GitHub outputs" >&2;}

    echo "" >&2
    echo -e "${GREEN}✓ Checkov report parsing and markdown generation completed successfully!${NC}" >&2
    echo -e "${GREEN} - ${BOLD}$MARKDOWN_FILE${NC} (markdown format)" >&2
    echo -e "${GREEN} - ${BOLD}$OUTPUT_FILE${NC} (markdown format)" >&2
    echo -e "${GREEN}✓ - Compliance score: $(Calculate_compliance)%${NC}" >&2
    echo "" >&2

    # Display markdown to stdout
    if [ -f "$MARKDOWN_FILE" ]; then
        cat "$MARKDOWN_FILE"
    else
        echo "⚠️ Warning: Markdown file was not created" >&2
        exit
    fi
}

# Run main function
main "$@"