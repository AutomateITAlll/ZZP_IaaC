# Setting up GitHub Actions with Azure

This guide provides instructions on how to set up GitHub Actions to deploy Azure resources.

## Create a Service Principal

To allow GitHub Actions to deploy resources to your Azure subscription, you need to create a Service Principal with appropriate permissions:

```bash
az ad sp create-for-rbac --name "github-actions-sp" --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/zzp2025
```

Replace `{subscription-id}` with your actual Azure subscription ID.

The command will output a JSON object similar to:

```json
{
  "appId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "displayName": "github-actions-sp",
  "password": "your-client-secret",
  "tenant": "tttttttt-tttt-tttt-tttt-tttttttttttt"
}
```

## Add the Service Principal details to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following secrets:

   a. Click on "New repository secret"
      - Name: `AZURE_CLIENT_ID`
      - Value: The `appId` value from the service principal creation output
      - Click "Add secret"

   b. Click on "New repository secret"
      - Name: `AZURE_CLIENT_SECRET`
      - Value: The `password` value from the service principal creation output
      - Click "Add secret"

   c. Click on "New repository secret"
      - Name: `AZURE_TENANT_ID`
      - Value: The `tenant` value from the service principal creation output
      - Click "Add secret"

   d. Click on "New repository secret"
      - Name: `AZURE_SUBSCRIPTION_ID`
      - Value: Your Azure subscription ID
      - Click "Add secret"

## Workflow File Structure

The GitHub Actions workflow file (`.github/workflows/azure-function-deploy.yml`) does the following:

1. Triggers on pushes to the main branch or manual workflow dispatch
2. Sets environment variables for resource group and location
3. Checks out the code repository
4. Sets up Node.js
5. Logs in to Azure using individual client credentials (Client ID, Client Secret, Tenant ID, and Subscription ID)
6. Checks if the resource group exists and creates it if needed
7. Deploys the Bicep template
8. Gets the function app name from the deployment outputs
9. Packages the function app code
10. Deploys the function app code
11. Logs out from Azure

## Monitoring Deployments

You can monitor the progress of your deployments:

1. Go to the "Actions" tab in your GitHub repository
2. Click on the running or completed workflow
3. You can see the logs for each step in the workflow

## Troubleshooting

- If deployment fails due to authentication issues, check that your service principal has the correct permissions and that the secret is correctly configured in GitHub
- If the Bicep deployment fails, check the Bicep template for errors
- If the function deployment fails, check the function code and configuration
