#!/bin/bash

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# install docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Allow docker for ubuntu user
usermod -aG docker ubuntu

IMAGE="${image_repo}:${image_tag}"
AWS_REGION="${aws_region}"
ACCOUNT_ID="${aws_account_id}"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws ecr get-login-password --region ${AWS_REGION} | \
docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# If your image is in ECR and requires login, prefer an IAM instance role.
# Optional: add aws ecr get-login-password | docker login ... here if you must.

docker pull $IMAGE || true

# Stop previous container (if exists) then run
docker rm -f strapi || true
docker run -d --name strapi \
  -p 1337:1337 \
  -e NODE_ENV=production \
  -e DATABASE_CLIENT=postgres \
  -v /var/lib/strapi:/srv/app/data \
  $IMAGE





