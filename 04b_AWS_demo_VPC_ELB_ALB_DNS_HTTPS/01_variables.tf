variable "aws_region" {}
variable "cidr_vpc" {}
variable "cidr_subnet_public_bastion" {}
variable "cidr_subnets_public_lb" {}
variable "cidr_subnets_private_websrv" {}
variable "authorized_ips" {}
variable "websrv_az" {}
variable "websrv_inst_type" {}
variable "websrv_public_sshkey_path" {}
variable "websrv_private_sshkey_path" {}
variable "websrv_cloud_init_script" {}
variable "bastion_az" {}
variable "bastion_inst_type" {}
variable "bastion_public_sshkey_path" {}
variable "bastion_private_sshkey_path" {}
variable "bastion_cloud_init_script" {}
variable "dns_name" {}
variable "dns_name2" {}
variable "dns_domain" {}
variable "dns_zone_id" {}
