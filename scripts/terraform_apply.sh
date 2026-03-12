#!/bin/bash

# Run Terraform Apply Script

cd ${TERRAFORM_DIR}

terraform init
terraform validate
terraform apply -auto-approve | tee terraform_apply.log