# Task 1: EC2 Static Website Hosting using Nginx

## Overview
This task involves deploying a static resume website on an AWS EC2 instance using the Nginx web server. 
A Free Tier Amazon Linux 2023 EC2 instance was launched in a public subnet with a public IP address. 
Nginx was installed through SSH access, and a custom HTML resume file was placed in `/usr/share/nginx/html` to replace the default Nginx page.

## Steps Performed
1. Launched a **t2.micro** Amazon Linux EC2 instance in the default VPC (public subnet).
2. Configured a Security Group allowing:
   - **Port 22 (SSH)** from My IP
   - **Port 80 (HTTP)** from anywhere (0.0.0.0/0)
3. Connected to the instance using SSH.
4. Installed and started Nginx:
