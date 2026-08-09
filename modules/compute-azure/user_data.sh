#!/bin/bash
set -euxo pipefail

# 2G swap: B1s only has 1 GB of RAM
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
usermod -aG docker ${admin_username}

# Hardening: automatic security patches + SSH brute-force protection
apt-get install -y unattended-upgrades fail2ban

%{ if stack_repo_url != "" ~}
git clone ${stack_repo_url} /opt/tfg-stack
cd /opt/tfg-stack
docker compose up -d --build
%{ endif ~}
