#!/bin/bash
set -e
mkdir -p nginx/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/certs/server.key -out nginx/certs/server.crt \
  -subj "/C=VN/ST=ThaiNguyen/O=BookingTour/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
chmod 644 nginx/certs/server.crt nginx/certs/server.key
echo "Đã tạo chứng chỉ trong nginx/certs/"
