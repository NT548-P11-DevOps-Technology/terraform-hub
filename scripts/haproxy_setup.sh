#!/bin/bash

sudo apt update
sudo apt install haproxy -y
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo apt install net-tools -y
sudo curl https://dl.min.io/client/mc/release/linux-ppc64le/mc \
    --create-dirs \
    -o ~/minio-binaries/mc
sudo chmod +x $HOME/minio-binaries/mc
sudo export PATH=$PATH:$HOME/minio-binaries/
sudo mc alias set minio http://10.0.30.10:9000 ogXBMfE3Xi5Oypz9G2Bo nMgyxNjc3pGMICtGld9WK7EdEpE6AgQ9hu0XxtCw
sudo mkdir -p /etc/haproxy/certs
sudo touch /etc/haproxy/certs/th1enlm02.live.pem
sudo chmod 600 /etc/haproxy/certs/th1enlm02.live.pem