#!/bin/bash
set -euxo pipefail

# 2G swap: t3.micro only has 1 GB of RAM
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Docker from the official repository
apt-get update
apt-get install -y ca-certificates curl gnupg git
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker ubuntu

# Hardening: automatic security patches + SSH brute-force protection
apt-get install -y unattended-upgrades fail2ban

%{ if stack_repo_url != "" ~}
git clone ${stack_repo_url} /opt/tfg-stack
cd /opt/tfg-stack

%{ if discord_webhook_param != "" ~}
# Fetch the webhook from SSM using the instance role; the secret never
# touches Terraform state, user_data text or the repository.
apt-get install -y awscli
WEBHOOK=$(aws ssm get-parameter --name "${discord_webhook_param}" --region "${aws_region}" --query Parameter.Value --output text)
echo "DISCORD_WEBHOOK_URL=$WEBHOOK" > .env
chmod 600 .env
%{ endif ~}

docker compose up -d --build
%{ endif ~}
