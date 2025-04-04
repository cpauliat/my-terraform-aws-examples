# ------ Create a VPC 
resource aws_vpc demo01 {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  tags                 = { Name = "demo01-vpc" }
}

# ------ Create an internet gateway in the new VPC
resource aws_internet_gateway demo01 {
  vpc_id = aws_vpc.demo01.id
  tags   = { Name = "demo01-igw" }
}

# ------ Add a name and route rule to the default route table
resource aws_default_route_table demo01 {
  default_route_table_id = aws_vpc.demo01.default_route_table_id
  tags                   = { Name = "demo01-rt" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo01.id
  }
}

# ------ Add a name to the default network ACL and modify ingress rules
resource aws_default_network_acl demo01 {
  default_network_acl_id = aws_vpc.demo01.default_network_acl_id
  tags                   = { Name = "demo01-acl" }
  subnet_ids             = [ aws_subnet.demo01_public.id ]

  dynamic ingress {
    for_each = var.authorized_ips
    content {
      protocol   = "tcp"
      rule_no    = 100 + 10 * index(var.authorized_ips, ingress.value)
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 22
      to_port    = 22
    }
  }

  # for EC2 instance connect
  dynamic ingress {
    for_each = local.ec2_instance_connect_cidrs
    content {
      protocol   = "tcp"
      rule_no    = 200 + 10 * index(local.ec2_instance_connect_cidrs, ingress.value)
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 22
      to_port    = 22
    }
  }

  # this is needed for yum
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# ------ Create a subnet (use the default route table and default network ACL)
resource aws_subnet demo01_public {
  vpc_id                  = aws_vpc.demo01.id
  availability_zone       = "${var.aws_region}${var.az}"
  cidr_block              = var.cidr_subnet1
  map_public_ip_on_launch = true
  tags                    = { Name = "demo01-public" }
}

# ------ get prefix list and cidrs for EC2 instance connect in this region
data aws_ec2_managed_prefix_list ec2_instance_connect {
  name = "com.amazonaws.${var.aws_region}.ec2-instance-connect"
}

locals {
  ec2_instance_connect_cidrs = tolist(data.aws_ec2_managed_prefix_list.ec2_instance_connect.entries)[*].cidr
}

# ------ Customize the security group for the EC2 instance
resource aws_default_security_group demo01 {
  vpc_id      = aws_vpc.demo01.id
  tags        = { Name = "demo01-sg1" }

  # ingress rule: allow SSH
  ingress {
    description = "allow SSH access from authorized public IP addresses"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.authorized_ips
  }

  # ingress rule: allow SSH from EC2 Instance Connect
  ingress {
    description        = "allow SSH access from EC2 Instance Connect"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    prefix_list_ids   = [data.aws_ec2_managed_prefix_list.ec2_instance_connect.id]
  }

  # egress rule: allow all traffic
  egress {
    description = "allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"    # all protocols
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

output ec2_instance_connect_cidrs {
  value = local.ec2_instance_connect_cidrs
}