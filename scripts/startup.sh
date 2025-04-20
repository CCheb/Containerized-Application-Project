#!/bin/bash

LOGFILE="/var/log/deploy.log"

echo "Startup script started at $(date)" | tee -a "$LOGFILE"

# Run the LVM configuration script (before Docker setup)
if [ -f "/home/ubuntu/configure-lvm.sh" ]; then
  echo "Running LVM configuration..." | tee -a "$LOGFILE"
  bash /home/ubuntu/configure-lvm.sh | tee -a "$LOGFILE"
else
  echo "LVM configuration script not found!" | tee -a "$LOGFILE"
  exit 1
fi

# Update system and install necessary packages
apt update && apt install -y docker.io docker-compose git | tee -a "$LOGFILE"

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Add ubuntu to docker group
usermod -aG docker ubuntu

cd /home/ubuntu

# Clone or pull repo
if [ -d "Containerized-Application-Project" ]; then
  echo "Project repo already exists. Pulling updates..." | tee -a "$LOGFILE"
  cd Containerized-Application-Project && git pull | tee -a "$LOGFILE"
else
  echo "Cloning project repo..." | tee -a "$LOGFILE"
  git clone https://github.com/CCheb/Containerized-Application-Project.git | tee -a "$LOGFILE"
  cd Containerized-Application-Project
fi

# Make deploy.sh executable
chmod +x deploy.sh

# Run deploy script and log output
./deploy.sh | tee -a "$LOGFILE"
