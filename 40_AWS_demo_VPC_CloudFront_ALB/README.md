1 VPC with 5 subnets:

- public subnet for bastion host (EC2)
- 2 private subnets for Application Load Balancer (ALB) in 2 different AZs
- 2 private subnets for WebServers hosts (EC2) in 2 different AZs

3 EC2 instances (Linux):

- 1 bastion host (used to SSH to WebServer instances in private subnets)
- 2 WebServer instances in private subnets

1 ALB (application load balancer) using 2 private subnets

- in front of the 2 EC2 instances for Web Servers

1 CloudFront distribution:

- in front of ALB

1 Global Accelerator to route traffic from CloudFront distribution to ALB in private subnets
