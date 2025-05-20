# Setup Azure Service Principal for GitHub Actions
# This script creates a service principal and outputs the necessary values for GitHub Actions

# Parameters
$spName = "github-actions-sp"
$resourceGroupName = "zzp2025"
$subscriptionId = (az account show --query id -o tsv)

Write-Host "Creating Service Principal for GitHub Actions..." -ForegroundColor Green

# Create the service principal
$sp = az ad sp create-for-rbac --name $spName --role contributor --scopes /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName | ConvertFrom-Json

Write-Host "`nService Principal created successfully!`n" -ForegroundColor Green
Write-Host "Add the following secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "----------------------------------------------" -ForegroundColor Yellow
Write-Host "AZURE_CLIENT_ID: $($sp.appId)" -ForegroundColor Cyan
Write-Host "AZURE_CLIENT_SECRET: $($sp.password)" -ForegroundColor Cyan
Write-Host "AZURE_TENANT_ID: $($sp.tenant)" -ForegroundColor Cyan
Write-Host "AZURE_SUBSCRIPTION_ID: $subscriptionId" -ForegroundColor Cyan
Write-Host "----------------------------------------------" -ForegroundColor Yellow

Write-Host "`nTo add these to your GitHub repository:" -ForegroundColor Green
Write-Host "1. Go to your GitHub repository" -ForegroundColor White
Write-Host "2. Go to Settings > Secrets and variables > Actions" -ForegroundColor White
Write-Host "3. Click on 'New repository secret'" -ForegroundColor White
Write-Host "4. Add each of the secrets above with their corresponding values" -ForegroundColor White
