#!/bin/bash
yum update -y

# Enable nginx for Amazon Linux 2
amazon-linux-extras enable nginx1
yum clean metadata

# Install nginx and SSM agent
yum install -y nginx amazon-ssm-agent

# Start and enable services
systemctl start nginx
systemctl enable nginx

# Custom page
echo "Hello from GREEN ASG" > /usr/share/nginx/html/index.html

# Start and enable SSM Agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent