# Setup Azure OIDC for GitHub Actions
# This script creates an Azure AD application and sets up federated credentials for GitHub Actions OIDC

# Parameters - replace these with your values
$appName = "github-actions-oidc"
$resourceGroupName = "zzp2025"
$githubOrg = "<YOUR-GITHUB-ORG>"     # Replace with your GitHub org/username
$githubRepo = "<YOUR-GITHUB-REPO>"   # Replace with your GitHub repository name

# Get subscription ID
$subscriptionId = (az account show --query id -o tsv)
$tenantId = (az account show --query tenantId -o tsv)

Write-Host "Setting up OIDC Authentication for GitHub Actions with Azure..." -ForegroundColor Green
Write-Host "Using subscription ID: $subscriptionId" -ForegroundColor Cyan

# Create the Azure AD application
Write-Host "Creating Azure AD application: $appName" -ForegroundColor Yellow
$app = az ad app create --display-name $appName | ConvertFrom-Json
Write-Host "Azure AD application created. App ID: $($app.appId)" -ForegroundColor Green

# Create a service principal for the application
Write-Host "Creating service principal for the application..." -ForegroundColor Yellow
$sp = az ad sp create --id $app.appId | ConvertFrom-Json
Write-Host "Service principal created. Object ID: $($sp.id)" -ForegroundColor Green

# Assign contributor role to the service principal for the resource group
Write-Host "Assigning Contributor role to the service principal for resource group: $resourceGroupName" -ForegroundColor Yellow
az role assignment create --role contributor --subscription $subscriptionId --assignee-object-id $sp.id --assignee-principal-type ServicePrincipal --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName
Write-Host "Role assignment created." -ForegroundColor Green

# Create federated identity credential for GitHub Actions
Write-Host "Creating federated identity credential for GitHub Actions..." -ForegroundColor Yellow
$credentialParams = @{
    name = "github-actions"
    issuer = "https://token.actions.githubusercontent.com"
    subject = "repo:$githubOrg/$githubRepo:ref:refs/heads/main"
    audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Compress

az ad app federated-credential create --id $app.id --parameters $credentialParams
Write-Host "Federated identity credential created." -ForegroundColor Green

Write-Host "`nOIDC setup completed successfully!`n" -ForegroundColor Green
Write-Host "Add the following secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "----------------------------------------------" -ForegroundColor Yellow
Write-Host "AZURE_CLIENT_ID: $($app.appId)" -ForegroundColor Cyan
Write-Host "AZURE_TENANT_ID: $tenantId" -ForegroundColor Cyan
Write-Host "AZURE_SUBSCRIPTION_ID: $subscriptionId" -ForegroundColor Cyan
Write-Host "----------------------------------------------" -ForegroundColor Yellow

Write-Host "`nTo add these to your GitHub repository:" -ForegroundColor Green
Write-Host "1. Go to your GitHub repository" -ForegroundColor White
Write-Host "2. Go to Settings > Secrets and variables > Actions" -ForegroundColor White
Write-Host "3. Click on 'New repository secret'" -ForegroundColor White
Write-Host "4. Add each of the secrets above with their corresponding values" -ForegroundColor White
Write-Host "`nMake sure your workflows have the following permissions:" -ForegroundColor Red
Write-Host "permissions:" -ForegroundColor White
Write-Host "  id-token: write" -ForegroundColor White
Write-Host "  contents: read" -ForegroundColor White
