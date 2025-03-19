#!/bin/bash

# 기본 패키지 업데이트
sudo apt update && sudo apt upgrade -y

# NginX 설치
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Redis 설치
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Docker 설치
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Docker 권한 추가 (옵션)
sudo usermod -aG docker $USER

sudo apt update
sudo apt install certbot python3-certbot-nginx -y