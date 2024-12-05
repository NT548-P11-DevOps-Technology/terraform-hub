#!/bin/bash

sudo apt update
sudo apt install haproxy -y
sudo systemctl start haproxy
sudo systemctl enable haproxy