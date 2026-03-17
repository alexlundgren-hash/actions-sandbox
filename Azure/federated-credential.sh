#!/bin/bash


SUBSCRIPTION_ID=$(az account show --query id -o tsv)
RG=<your-resource-group>
YOUR_GITHUB_ORG=<your-github-org>
YOUR_REPO=<your-repo>

# User-Assigned Managed Identity
az identity create --name github-actions-identity --resource-group $RG
PRINCIPAL_ID=$(az identity show --name github-actions-identity --resource-group $RG --query principalId -o tsv)
az role assignment create --assignee $PRINCIPAL_ID --role "Contributor" --scope "/subscriptions/SUBSCRIPTION_ID"

# Create the trust relationship with your GitHub Repo
az identity federated-credential create \
  --name GitHubActions \
  --identity-name github-actions-identity \
  --resource-group $RG \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:$YOUR_GITHUB_ORG/$YOUR_REPO:ref:refs/heads/main" \
  --audience "api://AzureADTokenExchange"
