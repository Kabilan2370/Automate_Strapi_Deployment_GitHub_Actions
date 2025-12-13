#!/bin/bash

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

apt-get update -y
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip

# install docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

systemctl start docker
systemctl enable docker


# Allow docker for ubuntu user
usermod -aG docker ubuntu


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws ecr get-login-password --region ${aws_region} | \
docker login --username AWS --password-stdin ${image_repo}

cat <<EOF > /home/ubuntu/.env
NODE_ENV=production
ADMIN_JWT_SECRET=admin123
JWT_SECRET=jwt123
APP_KEYS=VPXRhnkNBdN0vJ1ij4vwmJEF/ZA/HXvOxT5Xcd/IQjc=,gn7T/0z8mUXPIyUR/eg56ScOmdP3wly+kUz6MvE22Xc=,iuFsOmJiIIJptaGrv7w45BOEUDTLk73eMcBd6dVM+bE=,pf62g1k+rigKtemW1mRXVI6P1Bt9nze95ZNDf24ns2E=
EOF

# Stop old container if exists
docker rm -f strapi || true

docker run -d --name strapi \
  -p 1337:1337 \
  -e NODE_ENV=production \
  -e DATABASE_CLIENT=postgres \
  -v /var/lib/strapi:/srv/app/data \
  --env-file /home/ubuntu/.env \
  ${image_repo}:${image_tag}









