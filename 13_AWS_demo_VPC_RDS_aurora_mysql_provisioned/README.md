# AWS VPC with RDS Aurora MySQL Provisioned Demo

This Terraform project creates a complete AWS infrastructure setup with a VPC, RDS Aurora MySQL cluster, and an EC2 instance configured as a database client.

## Architecture Overview

The infrastructure includes:
- **VPC** with custom CIDR block
- **Public subnet** for the database client instance
- **Private subnets** (3 AZs) for RDS Aurora MySQL cluster
- **EC2 instance** (Amazon Linux 2023) with MySQL client pre-installed
- **RDS Aurora MySQL cluster** with provisioned instances
- **Security groups** with proper ingress/egress rules
- **SSH key pair** for secure instance access

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 0.12 installed
- SSH key pair generated (handled automatically by Terraform)

## Configuration

### Required Variables

Copy `terraform.tfvars.TEMPLATE` to `terraform.tfvars` and configure the following variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `"eu-west-3"` |
| `cidr_vpc` | VPC CIDR block | `"192.168.0.0/16"` |
| `cidr_client_subnet` | Public subnet for DB client | `"192.168.0.0/24"` |
| `cidr_rds_subnets` | Private subnets for RDS (3 AZs) | `["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]` |
| `authorized_ips` | IPs allowed SSH access | `["YOUR_IP/32"]` |
| `public_sshkey_path` | Path to public SSH key | `"sshkeys_generated/ssh_key_demo13.pub"` |
| `private_sshkey_path` | Path to private SSH key | `"sshkeys_generated/ssh_key_demo13"` |
| `db_client_az` | Availability zone for DB client | `"b"` |
| `db_client_private_ip` | Private IP for DB client | `"192.168.0.11"` |
| `db_client_inst_type` | EC2 instance type for DB client | `"t3a.large"` |
| `db_client_cloud_init_script` | Cloud-init script path | `"cloud_init/cloud_init_al2023_TEMPLATE.sh"` |
| `aurora_subnets_azs` | Availability zones for Aurora subnets | `["a", "b", "c"]` |
| `aurora_mysql_db_identifier` | Aurora instance identifier | `"demo13-aurora-inst"` |
| `aurora_mysql_cluster_identifier` | Aurora cluster identifier | `"demo13-aurora-mysql-cluster"` |
| `aurora_mysql_engine_version` | Aurora MySQL version | `"8.0.mysql_aurora.3.08.2"` |
| `aurora_mysql_username` | Master username | `"admin"` |
| `aurora_mysql_instance_class` | RDS instance type | `"db.r6g.large"` |
| `aurora_mysql_db_name` | Initial database name | `"db1"` |
| `aurora_mysql_size_in_gbs` | Allocated storage in GB | `"40"` |

### Aurora MySQL Configuration

- **Cluster Identifier**: Unique name for the Aurora cluster
- **Database Name**: Initial database to create
- **Username**: Master username for database access
- **Storage**: Allocated storage in GB
- **Multi-AZ**: Deployed across 3 availability zones

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Confirm deployment** by typing `yes` when prompted.

## Usage

After successful deployment, Terraform will output SSH connection instructions:

### Connect to Database Client Instance

```bash
ssh -i sshkeys_generated/ssh_key_demo13 ec2-user@<PUBLIC_IP>
```

### Connect to MySQL Database

Once connected to the EC2 instance:

```bash
export MYSQL_PASSWD=<generated_password>
./mysql.sh
```

### MySQL Operations

Common MySQL commands available after connection:

```sql
-- List databases
show databases;

-- Select database
use db1;

-- List tables
show tables;

-- Create sample table
create table tblEmployee
(
Employee_id int auto_increment primary key,
Employee_first_name varchar(500) NOT null,
Employee_last_name varchar(500) NOT null,
Employee_Address varchar(1000),
Employee_emailID varchar(500),
Employee_department_ID int default 9,
Employee_Joining_date date 
);

-- Insert sample data
insert into tblEmployee (employee_first_name, employee_last_name, employee_joining_date) 
values ('John','Doe','2024-01-15');

-- Query data
select * from tblEmployee;
```

## Security Features

- **VPC Isolation**: RDS cluster deployed in private subnets
- **Security Groups**: Restrictive ingress rules
- **SSH Key Authentication**: No password-based access
- **IP Whitelisting**: Only authorized IPs can access the instance
- **Random Password Generation**: Secure database passwords

## File Structure

```
├── 01_variables.tf                    # Variable definitions
├── 02_provider.tf                     # AWS provider configuration
├── 03_network.tf                      # VPC, subnets, routing
├── 04_data_sources.tf                 # AWS data sources
├── 05_ssh_key_pair.tf                 # SSH key pair generation
├── 06_rds_aurora_mysql.tf             # Aurora MySQL cluster
├── 07_instance_linux_db_client.tf     # EC2 database client
├── 08_outputs.tf                      # Output values
├── 99_aws-whoami.tf                   # AWS identity verification
├── cloud_init/                        # Instance initialization scripts
│   ├── cloud_init_al2_TEMPLATE.sh     # Amazon Linux 2 cloud-init
│   └── cloud_init_al2023_TEMPLATE.sh  # Amazon Linux 2023 cloud-init
├── sshkeys_generated/                 # Generated SSH keys
├── list_versions_v1.sh                # List Aurora engine versions
├── list_versions_v2_v3.sh             # List Aurora MySQL versions
├── terraform.tfvars.TEMPLATE          # Template for variable values
└── terraform.tfvars                   # Variable values (not in repo)
```

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Confirm by typing `yes` when prompted.

## Cost Considerations

This setup includes:
- RDS Aurora MySQL cluster (primary cost driver)
- EC2 instance (t3a.large)
- EBS storage
- Data transfer costs

Estimated monthly cost varies by region and usage patterns. Use the [AWS Pricing Calculator](https://calculator.aws) for accurate estimates.

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**: Verify your IP is in `authorized_ips`
2. **Database Connection Failed**: Check security group rules and RDS status
3. **Terraform Apply Failed**: Ensure AWS credentials are properly configured

### Logs

- EC2 instance initialization: `/var/log/cloud-init2.log`
- Terraform state: `terraform.tfstate`
- AWS identity verification: `aws-whoami.log`

## Version Information

- Terraform: Compatible with 0.12+
- AWS Provider: Latest stable version
- Aurora MySQL: 8.0.mysql_aurora.3.08.2
- Amazon Linux: 2023 (latest AMI)

## Utility Scripts

### Aurora Version Discovery

Two utility scripts are provided to help you find available Aurora engine versions:

- `list_versions_v1.sh`: Lists available Aurora engine versions
- `list_versions_v2_v3.sh`: Lists available Aurora MySQL engine versions

Run these scripts to find the latest compatible versions for your deployment:

```bash
./list_versions_v1.sh
./list_versions_v2_v3.sh
```