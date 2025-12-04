# AWS VPC Networking Setup using Terraform

This project contains the Terraform configuration for creating a basic AWS network architecture. The setup includes one VPC, two public subnets, two private subnets, an Internet Gateway, a NAT Gateway, and route tables for public and private routing.

## Architecture Overview

The VPC is created with a CIDR block of 10.0.0.0/16 to provide sufficient IP range for subnet expansion. The network includes two public subnets that host internet-facing resources. Two private subnets are used to host internal systems that should not be directly accessible from the internet. An Internet Gateway is attached to enable public access, and a NAT Gateway is configured so that private subnets can reach the internet for updates without exposing them publicly. Route tables control the traffic flow for internet connectivity and internal communication.

## CIDR Ranges Used

VPC: 10.0.0.0/16  
Public Subnet 1: 10.0.1.0/24  
Public Subnet 2: 10.0.2.0/24  
Private Subnet 1: 10.0.3.0/24  
Private Subnet 2: 10.0.4.0/24
