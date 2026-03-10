#!/bin/bash
#
# Deployment script for Pbl Platform Infrastructure
# This script deploys the infrastructure in AWS using Terraform
#

set -e

# Configuration
REGION="${AWS_REGION:-us-east-1}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
# PROJECT_NAME="PBL-Platform-Infrastructure"
PROJECT_NAME="pbl-platform-infrastructure"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform >= 1.5.0"
        exit 1
    fi

    # check Terraform version
    TERRAFORM_VERSION=${terraform version -json | grep -o '"terraform_version": "[^"]*' | grep -o '[^"]*$'}
    log_info "Terraform version: $TERRAFORM_VERSION"

    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install AWS CLI."
        exit 1
    fi

    # Check AWS credentials
    if ! aws sts get-caller-identity --region "$REGION" &> /dev/null; then
        log_error "AWS credentials are not configured properly. Please configure AWS CLI."
        exit 1
    fi

    log_info "All prerequisites check passed."
}

# Initialize Terraform
init_terraform() {
    log_info "Initializing Terraform..."
    cd terraform
    terraform init
    log_info "Terraform initialized successfully."
}

# Create or select workspace
setup_workspace() {
    log_info "Setting up Terraform workspace for environment: $ENVIRONMENT"
    if terraform workspace list | grep -q "$ENVIRONMENT"; then
        log_info "Workspace $ENVIRONMENT already exists. Selecting it."
        terraform workspace select "$ENVIRONMENT"
    else
        terraform workspace new "$ENVIRONMENT"
        log_info "Creatingnew workspace: $ENVIRONMENT"
    fi
}

# Plan Terraform deployment
plan_terraform() {
    log_info "Planning Terraform deployment..."
    terraform plan \
        -var="aws_region=$REGION" \
        -var="project_name=$PROJECT_NAME" \
        -var="environment=$ENVIRONMENT" \
        -out=tfplan

    log_info "Terraform plan created. review the plan above."
    echo ""
    read -p "Do you want to proceed with the deployment? (yes/no): " CONFIRM

    if ["$CONFIRM" != "yes" ]; then
        log_warning "Deployment aborted by user."
        exit 0
    fi
}


# Apply Terraform deployment
apply_terraform() {
    log_error "Applying Terraform deployment..."
    terraform apply tfplan
    log_info "Terraform deployment applied successfully."   
}

# Display outputs
display_outputs() {
    log_info "Deployment Summary:"
    echo ""
    echo "Environment: $ENVIRONMENT"
    echo "Region: $REGION"
    echo ""

    log_info "Infrastructure Outputs:"
    terraform output
}

# Cleanup plan file
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -f tfplan
    log_info "Cleanup completed."
}

# Main execution
main() {
    log_info "Starting deployment of $PROJECT_NAME infrastructure for environment: $ENVIRONMENT in region: $REGION"
    echo ""

    check_prerequisites
    init_terraform
    setup_workspace
    validate_terraform
    plan_terraform
    apply_terraform
    display_outputs
    cleanup

    log_info "Deployment completed successfully."
    log_info "To destroy the infrastructure, run: cd terraformterraform destroy"
}

# Handle errors
trap 'log_error "An error occurred. Deployment failed."; cleanup; exit 1' ERR

# Run main function
main "$@"