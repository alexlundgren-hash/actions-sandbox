# Terraform Azure Setup Guide

## Overview
This Terraform configuration provisions an Azure resource group named `rg-from-gh-actions` using GitHub Actions. State is stored in an Azure Storage Account.

## Prerequisites

### 1. Azure Storage Account for State
Scripts in `../Azure`

### 2. GitHub Secrets
Add the following secrets to your GitHub repository (Settings → Secrets and Variables → Actions):

- `AZURE_RESOURCE_GROUP_NAME`: Resource group containing the storage account (e.g., `tfstate`)
- `AZURE_STORAGE_ACCOUNT_NAME`: Storage account name (e.g., `tfstate12345`)
- `AZURE_STORAGE_CONTAINER_NAME`: Container name (e.g., `tfstate`)
- `AZURE_STATE_FILE_KEY`: Path to the state file (e.g., `terraform.tfstate`)
- `AZURE_STORAGE_ACCOUNT_KEY`: Storage account access key (from step above)

## Workflow Behavior

### On Pull Request
- Runs `terraform fmt`, `terraform validate`, and `terraform plan`
- Posts plan output as a PR comment

### On Push to Main
- Runs all validation checks
- Executes `terraform apply` automatically
- Displays outputs after successful apply

### Manual Trigger
- Run via GitHub Actions UI for immediate provisioning

## File Structure

```
Terraform/
├── main.tf          # Resource group resource
├── variables.tf     # Input variables
└── outputs.tf       # Output values

.github/workflows/
└── terraform-azure.yml  # GitHub Actions workflow
```

## Local Development

To run Terraform locally:

```bash
cd Terraform

# Initialize with remote backend
terraform init \
  -backend-config="resource_group_name=$RESOURCE_GROUP_NAME" \
  -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
  -backend-config="container_name=$CONTAINER_NAME" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="access_key=$ARM_ACCESS_KEY"

# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Outputs

After provisioning, the following outputs are available:
- `resource_group_id`: Full ID of the resource group
- `resource_group_name`: Name of the resource group
- `resource_group_location`: Azure region of the resource group
