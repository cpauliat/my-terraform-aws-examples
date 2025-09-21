# AWS API Gateway REST API with Cognito Authentication and Lambda Integration

This Terraform configuration creates a secure REST API using AWS API Gateway with Cognito User Pool authentication and Lambda function integration.

## Architecture Overview

The infrastructure creates:
- **AWS Lambda Function**: A Python-based serverless function that returns a simple "hello world" message
- **Amazon Cognito User Pool**: Provides user authentication and authorization
- **API Gateway REST API**: Exposes the Lambda function via HTTP endpoints with Cognito authentication
- **CloudWatch Logs**: For API Gateway logging and monitoring

## Resources Created

### Lambda Function
- **Function Name**: `demo33c`
- **Runtime**: Python 3.11
- **Handler**: `lambda.lambda_handler`
- **IAM Role**: Includes basic Lambda execution permissions
- **Source**: `lambda.py` (packaged as `lambda_function_payload.zip`)

### Cognito User Pool
- **User Pool**: `demo33c-pool`
- **Client**: `demo33c-client-apigw` with OAuth flows enabled
- **User**: Created with configurable username and auto-generated secure password
- **OAuth Scopes**: `aws.cognito.signin.user.admin`, `email`, `openid`, `profile`
- **Auth Flows**: `ADMIN_NO_SRP_AUTH`, `USER_PASSWORD_AUTH`

### API Gateway
- **API Type**: REST API (Regional endpoint)
- **API Name**: `demo33c`
- **Resource Path**: Configurable via `apigw_path1` variable (default: `/path1`)
- **HTTP Method**: GET
- **Authorization**: Cognito User Pools
- **Stage**: `demo33c-stage1`
- **Integration**: Lambda proxy integration

### CloudWatch Logs
- **Log Group**: `/aws/apigateway/demo33c`
- **Retention**: 14 days

## Configuration

### Required Variables
Create a `terraform.tfvars` file based on `terraform.tfvars.TEMPLATE`:

```hcl
aws_region        = "eu-west-1"    # AWS region
apigw_path1       = "path1"        # API Gateway resource path
cognito_user_name = "chris"        # Cognito user name
```

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Create variables file**:
   ```bash
   cp terraform.tfvars.TEMPLATE terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Plan deployment**:
   ```bash
   terraform plan
   ```

4. **Apply configuration**:
   ```bash
   terraform apply
   ```

## Testing the API

After deployment, Terraform outputs testing instructions:

### 1. Test Unauthorized Access
```bash
curl -i https://<api-id>.execute-api.<region>.amazonaws.com/demo33c-stage1/path1
```
This should return `401 Unauthorized` since authentication is required.

### 2. Generate Access Token
```bash
aws cognito-idp admin-initiate-auth \
    --region <region> \
    --client-id <client-id> \
    --user-pool-id <user-pool-id> \
    --auth-flow ADMIN_NO_SRP_AUTH \
    --auth-parameters USERNAME=<username>,PASSWORD=<password>
```

### 3. Test Authorized Access
```bash
TOKEN=<IdToken-from-previous-command>
curl -i \
    -H "Authorization: Bearer $TOKEN" \
    https://<api-id>.execute-api.<region>.amazonaws.com/demo33c-stage1/path1
```

## Security Features

- **Authentication**: Cognito User Pool ensures only authenticated users can access the API
- **Authorization**: API Gateway authorizer validates Cognito tokens
- **IAM Roles**: Least privilege access for Lambda and API Gateway
- **Secure Password**: Auto-generated password with complexity requirements
- **CloudWatch Logging**: API access logging for monitoring and auditing

## File Structure

```
├── 01_variables.tf           # Variable definitions
├── 02_provider.tf           # AWS provider configuration
├── 03_lambda.tf             # Lambda function and IAM role
├── 04_cognito_user_pool.tf  # Cognito user pool and user
├── 05_api_gateway_rest.tf   # API Gateway REST API configuration
├── 99_aws-whoami.tf         # AWS account information
├── lambda.py                # Lambda function source code
├── terraform.tfvars.TEMPLATE # Template for variables
└── README.md                # This file
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Notes

- The Lambda function returns a simple JSON response: `{"message": "hello world demo33c"}`
- Cognito user password is randomly generated and displayed in Terraform output
- API Gateway uses regional endpoints for better performance
- CloudWatch logs are retained for 14 days