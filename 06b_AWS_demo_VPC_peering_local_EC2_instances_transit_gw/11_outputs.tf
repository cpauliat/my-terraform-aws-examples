# ------ Display the complete ssh command needed to connect to the instance
locals {
  username = "ec2-user"
}

output Instances {
  value = <<EOF


---- You can SSH directly to the Linux EC2 instances by typing the following ssh command
instance in VPC #1: ssh -i ${var.private_sshkey_path} ${local.username}@${aws_eip.demo06b_inst1.public_ip}
instance in VPC #2: ssh -i ${var.private_sshkey_path} ${local.username}@${aws_eip.demo06b_inst2.public_ip}
instance in VPC #2: ssh -i ${var.private_sshkey_path} ${local.username}@${aws_eip.demo06b_inst3.public_ip}

---- Once connected to instance in VPC #1, you can ping instance in other VPCs
To VPC #2: $ ping ${aws_instance.demo06b_inst2.private_ip}  
To VPC #3: $ ping ${aws_instance.demo06b_inst3.private_ip}

---- OR once connected to instance in VPC #2, you can ping instance in other VPCs
To VPC #3: $ ping ${aws_instance.demo06b_inst3.private_ip}  
To VPC #1: $ ping ${aws_instance.demo06b_inst1.private_ip}

---- OR once connected to instance in VPC #3, you can ping instance in other VPCs
To VPC #1: $ ping ${aws_instance.demo06b_inst1.private_ip}  
To VPC #2: $ ping ${aws_instance.demo06b_inst2.private_ip}

EOF
}