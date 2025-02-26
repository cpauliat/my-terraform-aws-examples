variable "aws_region" {}
variable "az" {}
variable "cidr_vpc" {}
variable "cidr_subnet_public" {}
variable "cidr_subnets_private_lb" {}
variable "cidr_subnets_private_websrv" {}
variable "authorized_ips" {}
variable "websrv_nb_instances" {}
variable "websrv_inst_type" {}
variable "websrv_public_sshkey_path" {}
variable "websrv_private_sshkey_path" {}
variable "websrv_cloud_init_script" {}
variable "bastion_inst_type" {}
variable "bastion_public_sshkey_path" {}
variable "bastion_private_sshkey_path" {}
variable "bastion_cloud_init_script" {}
