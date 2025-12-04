# High Availability Architecture with ALB & Auto Scaling Group

## Overview
This setup implements a highly available, scalable, and secure architecture on AWS. 
The goal is to enhance the static website deployment by moving EC2 instances into private subnets and placing an internet-facing Application Load Balancer in front of them. The EC2 instances are automatically created and managed through an Auto Scaling Group that runs across multiple Availability Zones to achieve fault tolerance.

## Architecture Flow
User → Internet → Application Load Balancer (Public Subnets) → Target Group → EC2 instances (Private Subnets via ASG)

### Key Components
- **VPC** with public and private subnets in two Availability Zones
- **Internet Gateway** for public subnet internet access
- **Application Load Balancer** exposed publicly to receive user traffic
- **Target Group** routing traffic from ALB to EC2 instances
- **Auto Scaling Group** deployed in private subnets to maintain desired instance count
- **Launch Template** used for standardized EC2 provisioning with user-data web server setup
- **Security Groups** ensuring secure routing (Public → ALB only ; ALB → EC2 only)

### Benefits
- High availability and fault tolerance
- Instances stay private and secure
- Automatic scaling on demand
- Even distribution of traffic across AZs

---

## Steps Followed
1. Created VPC with four subnets (2 public + 2 private) across two AZs.
2. Configured NAT Gateway and route tables.
3. Created security groups for ALB and EC2 instances.
4. Built a Launch Template with a user-data script to start a webserver.
5. Created a Target Group for load balancing health checks.
6. Launched an internet-facing Application Load Balancer in public subnets.
7. Created an Auto Scaling Group in private subnets and attached the Target Group.
8. Verified that ASG-launched EC2 instances serve web pages through the ALB DNS endpoint.

