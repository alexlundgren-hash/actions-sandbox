#!/bin/bash

# Create a resource group to house your GitHub Actions managed identity
RG_NAME="gh-actions-managed-identity"
az group create --name "$RG_NAME" --location swedencentral

# Configuration
RG="$RG_NAME"
YOUR_GITHUB_ORG="your-github-org"
YOUR_REPO="your-repo"

# Automatically get Subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "Using Subscription: $SUBSCRIPTION_ID"

# 1. Create User-Assigned Managed Identity
echo "Creating Managed Identity..."
az identity create --name github-actions-identity --resource-group "$RG"

# Wait a few seconds for Azure AD to propagate the identity
sleep 5 

# 2. Get the Principal ID and Client ID
PRINCIPAL_ID=$(az identity show --name github-actions-identity --resource-group "$RG" --query principalId -o tsv)
CLIENT_ID=$(az identity show --name github-actions-identity --resource-group "$RG" --query clientId -o tsv)

echo "Principal ID: $PRINCIPAL_ID"
echo "Client ID: $CLIENT_ID"

# 3. Assign 'Contributor' role at Subscription Scope (The Fixed Line)
echo "Assigning Contributor role..."
az role assignment create \
    --assignee "$PRINCIPAL_ID" \
    --role "Contributor" \
    --scope "/subscriptions/$SUBSCRIPTION_ID"

# 4. Create the Federated Credential (OIDC Trust)
echo "Creating Federated Credential..."
az identity federated-credential create \
  --name GitHubActions \
  --identity-name github-actions-identity \
  --resource-group "$RG" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:$YOUR_GITHUB_ORG/$YOUR_REPO:ref:refs/heads/main" \
  --audience "api://AzureADTokenExchange"

echo "Done! Use Client ID $CLIENT_ID in your GitHub Secrets."
