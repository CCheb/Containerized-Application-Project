#!/bin/bash

# Navigate to the project directory
cd /home/amsebastian12/Containerized-Project || exit

# Pull the latest images and start the services with scaling
sudo docker-compose up -d --scale app=3
