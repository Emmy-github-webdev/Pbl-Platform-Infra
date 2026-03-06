#!/bin/bash

# Terraform CLI Installation

echo "Installing Terraform CLI..."

# Install HashiCorp GPG key
wget -o- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Verify the GPG key's fingerprint
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# Add the official HashiCorp Linux repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -op '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Terraform
sudo apt update

# Install Terraform version
echo "Installing Terraform version ${TF_VERSION}..."
sudo apt install -y terraform=${TF_VERSION}

# verify installation
echo "Verify Terraform installation..."
terraform -version
