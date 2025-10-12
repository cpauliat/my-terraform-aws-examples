# AWS VPC with EC2 Instance and CloudWatch Agent Demo

This Terraform project demonstrates AWS infrastructure setup with VPC, EC2 instance, and CloudWatch agent for comprehensive system monitoring.

## Architecture Overview

- **VPC** with public subnet
- **EC2 instance** with IAM role for CloudWatch access
- **CloudWatch agent** for automated system metrics collection
- **Auto-generated SSH keys** for secure instance access

## Infrastructure Components

### Network
- VPC with configurable CIDR block
- Public subnet for EC2 instance

### Compute
- **EC2 Instance**: Amazon Linux 2 with CloudWatch agent installed
- **Stress testing tools**: Pre-installed stress-ng for load generation

### Monitoring
- IAM role with CloudWatchAgentServerPolicy
- CloudWatch agent for system metrics (CPU, memory, disk, network)
- Automated metric collection and publishing

## Prerequisites

- Terraform installed
- AWS CLI configured with appropriate credentials
- SSH client for connecting to instances

## Setup Instructions

1. **Clone and navigate to the project directory**

2. **Configure variables**
   ```bash
   cp terraform.tfvars.TEMPLATE terraform.tfvars
   ```
   Edit `terraform.tfvars` with your specific values:
   - AWS region
   - CIDR blocks for VPC and subnet
   - Authorized IP addresses for SSH access
   - Instance type and availability zone

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan the deployment**
   ```bash
   terraform plan
   ```

5. **Deploy the infrastructure**
   ```bash
   terraform apply
   ```

## Configuration Files

| File | Purpose |
|------|---------| 
| `01_variables.tf` | Variable definitions |
| `02_provider.tf` | AWS provider configuration |
| `03_network.tf` | VPC, subnet, and networking |
| `04_data_sources.tf` | AWS data sources |
| `05_ssh_key_pair.tf` | SSH key generation |
| `06_iam_role_for_cloudwatch.tf` | IAM role for CloudWatch access |
| `07_instance_linux.tf` | EC2 instance configuration |

## Usage

After deployment, wait a few minutes for the cloud-init scripts to complete, then:

### SSH Access
```bash
ssh -i sshkeys_generated/ssh_key_demo17.priv ec2-user@<INSTANCE-PUBLIC-IP>
```

### Generate Load for Testing
```bash
# Run stress test to generate CPU and memory load
./stress.sh
```

### Monitor CloudWatch Metrics
- Navigate to AWS CloudWatch console
- Check "CWAgent" namespace for detailed system metrics
- View CPU, memory, disk, and network usage trends
- Access pre-configured dashboards for comprehensive monitoring

### CloudWatch Agent Management
```bash
# Check agent status
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -c ssm:AmazonCloudWatch-linux -a query

# Restart agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -c ssm:AmazonCloudWatch-linux -a restart
```

## Security Features

- EC2 instance with minimal required IAM permissions
- Security groups with SSH access restrictions
- Auto-generated SSH key pairs
- IP-based access restrictions

## Cloud-Init Scripts

- Installs monitoring tools (zsh, nmap, stress-ng)
- Installs and configures CloudWatch agent
- Sets up stress testing capabilities
- Starts CloudWatch agent service

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Notes

- SSH keys are automatically generated in the `sshkeys_generated/` directory
- CloudWatch agent automatically collects system metrics
- The instance includes stress-ng for load testing scenarios
- Metrics appear in CloudWatch under "CWAgent" namespace
- Agent uses default configuration for comprehensive monitoring