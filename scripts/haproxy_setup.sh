#!/bin/bash

sudo apt update
sudo apt install haproxy -y
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo apt install net-tools -y
sudo curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  -o /usr/local/bin/mc
sudo chmod +x /usr/local/bin/mc
sudo mc alias set minio http://10.0.30.10:9000 ogXBMfE3Xi5Oypz9G2Bo nMgyxNjc3pGMICtGld9WK7EdEpE6AgQ9hu0XxtCw
sudo mkdir -p /etc/haproxy/certs
sudo mc cp minio/haproxy-config/th1enlm02.live.pem /etc/haproxy/certs/th1enlm02.live.pem
sudo chmod 600 /etc/haproxy/certs/th1enlm02.live.pem
sudo mc cp minio/haproxy-config/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy
