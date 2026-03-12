#!/bin/bash

set -euo pipefail

TERRAFORM_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$(BASH_SOURCE[0])")" && pwd)"

# Install checkov
pip install checkov -q

# Run checkov scan
echo "Running Checkov scan on Terraform directory: ${TERRAFORM_DIR}"
checkov -d "${TERRAFORM_DIR}" --compact --framework terraform --output > /tmp/checkov-output.txt 2>&1 || true

# Extract metrics
PASSED=$(grep -oP `(?<=Passed checks: )\d+` /tmp/checkov-output.txt || echo "0")
FAILED=$(grep -oP `(?<=Failed checks: )\d+` /tmp/checkov-output.txt || echo "0")
SKIPPED=$(grep -oP `(?<=Skipped checks: )\d+` /tmp/checkov-output.txt || echo "0")

# Output metrics to ITHUB_OUTPUTS
echo "passed=${PASSED}" >> "${GITHUB_OUTPUT}"
echo "failed=${FAILED}" >> "${GITHUB_OUTPUT}"
echo "skipped=${SKIPPED}" >> "${GITHUB_OUTPUT}"

# Save report for artifact
cp /tmp/checkov-output.txt checkov-report.txt

echo ""
echo "✓ Checkov scan completed"
echo "Passed: ${PASSED}"
echo "Failed: ${FAILED}"
echo "Skipped: ${SKIPPED}"

# Generate parsed report with color-coding and compliance scorecard
echo "Generating compliance scorecard..."
chmod +x "${SCRIPT_DIR}/parse-checkov-report.sh"
"${SCRIPT_DIR}/parse-checkov-report.sh" /tmp/checkov-output.txt checkov-report-parsed.txt

# Append parsed report to main report
cat "checkov-report-parsed.txt" >> checkov-report.txt

echo "✓ Compliance scorecard generated and appended to report"
echo " - checkov-report.txt (raw + parsed)"
echo " - checkov-report-parsed.txt (parsed only)"