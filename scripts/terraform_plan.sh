#!/bin/bash

# Run Terraform plan

cd ${TERRAFORM_DIR}

terraform init
terraform validate
terraform plan -lock=true -out=tfplan | tee terraform_plan.log