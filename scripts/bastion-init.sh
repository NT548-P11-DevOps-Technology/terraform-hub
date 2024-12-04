#!/bin/bash
sudo apt update
sudo apt-get update
sudo apt install net-tools -y
sudo apt install traceroute -y
sudo apt install haproxy -y
sudo apt install certbot -y
sudo apt install haproxy -y
sudo apt install iptables-persistent -y
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p
# https://docs.aws.amazon.com/vpc/latest/userguide/work-with-nat-instances.html
sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo netfilter-persistent save
sudo netfilter-persistent reload