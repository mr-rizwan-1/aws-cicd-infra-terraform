#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y docker.io fontconfig openjdk-21-jre
systemctl enable --now docker

# 2GB swap
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Jenkins repo (2026 signing key)
wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install -y jenkins

usermod -aG docker jenkins
usermod -aG docker ubuntu

# Avoid the "low /tmp space" node-offline issue we hit earlier
mount -o remount,size=2G /tmp || true

systemctl enable --now jenkins
systemctl restart jenkins