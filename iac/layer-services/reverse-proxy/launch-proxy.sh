#! /bin/bash

docker run --name my-custom-nginx-container -v ./nginx.conf:/etc/nginx/nginx.conf:ro -d nginx
