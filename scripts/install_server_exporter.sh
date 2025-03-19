#!/bin/bash

set -e  # 오류 발생 시 스크립트 중단

# Node Exporter 설치
NODE_EXPORTER_VERSION="1.7.0"
wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
tar -xzf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
sudo mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
rm -rf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*" 
sudo useradd --no-create-home --shell /bin/false node_exporter || true
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# Redis Exporter 설치
REDIS_EXPORTER_VERSION="1.54.0"
wget -q "https://github.com/oliver006/redis_exporter/releases/download/v${REDIS_EXPORTER_VERSION}/redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz"
tar -xzf "redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz"
sudo mv "redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64/redis_exporter" /usr/local/bin/
rm -rf "redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64*"
sudo useradd --no-create-home --shell /bin/false redis_exporter || true
sudo tee /etc/systemd/system/redis_exporter.service > /dev/null <<EOF
[Unit]
Description=Redis Exporter
After=network.target

[Service]
User=redis_exporter
ExecStart=/usr/local/bin/redis_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now redis_exporter
