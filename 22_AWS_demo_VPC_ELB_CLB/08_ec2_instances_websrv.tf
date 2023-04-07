# ------ Create an EC2 instances for web servers
resource aws_instance demo22_websrv {
  # wait for NAT gateway to be ready (needed by cloud-init script)
  depends_on = [
    aws_nat_gateway.demo22
  ]
  # ignore change in cloud-init file after provisioning
  lifecycle {
    ignore_changes = [
      user_data_base64
    ]
  }
  count                  = 3
  instance_type          = var.websrv_inst_type
  ami                    = data.aws_ami.al2_arm64.id
  key_name               = aws_key_pair.demo22_websrv.id
  subnet_id              = aws_subnet.demo22_private_websrv[count.index % 2].id
  vpc_security_group_ids = [ aws_security_group.demo22_sg_websrv.id ]
  tags                   = { Name = "demo22-websrv${count.index + 1}" }
  user_data_base64       = base64encode(replace(file(var.websrv_cloud_init_script),"<HOSTNAME>","websrv${count.index + 1}"))        
  root_block_device {
    encrypted   = true      # use default KMS key aws/ebs
    volume_type = "gp3"
    tags        = { "Name" = "demo22-websrv${count.index + 1}-boot" }
  }
}

# ------ Create a security group
resource aws_security_group demo22_sg_websrv {
  name        = "demo22-sg-websrv"
  description = "Description for demo22-sg-websrv"
  vpc_id      = aws_vpc.demo22.id
  tags        = { Name = "demo22-sg-websrv" }

  # Cycle error in Terraform
  # # ingress rule: allow HTTP
  # ingress {
  #   description = "allow HTTP access from load balancer"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   security_groups = [ aws_security_group.demo22_sg_alb.id ]
  # }

  # ingress rule: allow HTTP
  ingress {
    description = "allow HTTP access from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ var.cidr_vpc ]
  }

  # ingress rule: allow SSH from bastion host
  ingress {
    description     = "allow SSH access from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [ aws_security_group.demo22_sg_bastion.id ]
  }

  # # ingress rule: allow SSH
  # ingress {
  #   description = "allow SSH access from public subnet"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = [ var.cidr_vpc ]
  # }

  # egress rule: allow all traffic
  egress {
    description = "allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"    # all protocols
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}
