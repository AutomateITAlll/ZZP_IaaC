# Setting up GitHub Actions with Azure

This guide provides instructions on how to set up GitHub Actions to deploy Azure resources using Federated Identity Credentials (OIDC).

## Setting up OIDC Authentication with Azure

The OpenID Connect (OIDC) approach is more secure as it doesn't require storing long-lived secrets in your GitHub repository.

### 1. Create an Azure AD Application and Service Principal

```powershell
# Create the Azure AD application and service principal
$appName = "github-actions-oidc"
$app = az ad app create --display-name $appName | ConvertFrom-Json
$sp = az ad sp create --id $app.appId | ConvertFrom-Json

# Assign contributor role to the service principal for your resource group
az role assignment create --role contributor --subscription $subscriptionId --assignee-object-id $sp.id --assignee-principal-type ServicePrincipal --scope /subscriptions/{subscription-id}/resourceGroups/zzp2025
```

### 2. Configure Federated Identity Credentials

```powershell
# Get your GitHub organization and repository name
$githubOrg = "your-github-org"
$githubRepo = "your-github-repo"

# Create a credential for GitHub Actions
az ad app federated-credential create --id $app.id --parameters "{\"name\":\"github-actions\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$githubOrg/$githubRepo:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
```

### 3. Add the required secrets to GitHub

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following secrets:

   a. Click on "New repository secret"
      - Name: `AZURE_CLIENT_ID`
      - Value: The application ID from the created app (run `echo $app.appId`)
      - Click "Add secret"

   b. Click on "New repository secret"
      - Name: `AZURE_TENANT_ID`
      - Value: Your Azure tenant ID (run `az account show --query tenantId -o tsv`)
      - Click "Add secret"

   c. Click on "New repository secret"
      - Name: `AZURE_SUBSCRIPTION_ID`
      - Value: Your Azure subscription ID (run `az account show --query id -o tsv`)
      - Click "Add secret"

## Workflow File Configuration

The workflow files are already set up with the necessary permissions:

```yaml
permissions:
  id-token: write
  contents: read
```

And the login step is configured to use OIDC:

```yaml
- name: Login to Azure
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    enable-AzPSSession: true
```

## Workflow File Structure

The GitHub Actions workflow file (`.github/workflows/azure-function-deploy.yml`) does the following:

1. Triggers on pushes to the main branch or manual workflow dispatch
2. Sets required permissions for OIDC authentication
3. Sets environment variables for resource group and location
4. Checks out the code repository
5. Sets up Node.js
6. Logs in to Azure using OIDC authentication
7. Checks if the resource group exists and creates it if needed
8. Deploys the Bicep template
9. Gets the function app name from the deployment outputs
10. Packages the function app code
11. Deploys the function app code
12. Logs out from Azure

## Monitoring Deployments

You can monitor the progress of your deployments:

1. Go to the "Actions" tab in your GitHub repository
2. Click on the running or completed workflow
3. You can see the logs for each step in the workflow

## Troubleshooting

- If deployment fails due to authentication issues, check that your service principal has the correct permissions and that the secret is correctly configured in GitHub
- If the Bicep deployment fails, check the Bicep template for errors
- If the function deployment fails, check the function code and configuration
