#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y docker.io
systemctl enable --now docker
usermod -aG docker ubuntu