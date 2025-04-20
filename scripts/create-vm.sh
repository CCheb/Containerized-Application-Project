#!/bin/bash

# CONFIGURATION
VM_NAME="container-vm" # Change name to desired vm name
ZONE="us-central1-a" # Select the zone that the vm will be in
PROJECT_ID="$(gcloud config get-value project)"
MACHINE_TYPE="e2-micro"  # Lightweight and eligible for free tier
IMAGE_FAMILY="ubuntu-minimal-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
STARTUP_SCRIPT_URL="gs://bucket-name/startup.sh"  # Make sure this script exists
TAGS="docker-vm"

# Create the VM
echo "Creating VM $VM_NAME in $ZONE..."
gcloud compute instances create "$VM_NAME" \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type="$MACHINE_TYPE" \
  --image-family="$IMAGE_FAMILY" \
  --image-project="$IMAGE_PROJECT" \
  --metadata=startup-script-url="$STARTUP_SCRIPT_URL" \
  --tags="$TAGS" \
  --boot-disk-size=20GB \
  --boot-disk-type=pd-balanced

echo "VM $VM_NAME created and bootstrapping..."
