#!/bin/bash

# Configuration
DISK="/dev/sdb"
VG_NAME="docker_vg"

# Define apps with name, size, and mount path
declare -A apps=(
  [app1_data]="2G:/mnt/docker/app1"
  [app2_data]="2G:/mnt/docker/app2"
  [app3_data]="2G:/mnt/docker/app3"
  [db_data]="2G:/mnt/docker/db"
)

# Exit on error
set -e

echo "Starting LVM configuration..."

# Create physical volume
if ! pvdisplay "$DISK" &>/dev/null; then
  echo "Creating physical volume on $DISK..."
  pvcreate "$DISK"
else
  echo "Physical volume already exists."
fi

# Create volume group
if ! vgdisplay "$VG_NAME" &>/dev/null; then
  echo "Creating volume group $VG_NAME..."
  vgcreate "$VG_NAME" "$DISK"
else
  echo "Volume group already exists."
fi

# Create logical volumes
if ! lvdisplay "/dev/$VG_NAME/$LV_APP" &>/dev/null; then
  echo "Creating logical volume $LV_APP..."
  lvcreate -L "$SIZE_APP" -n "$LV_APP" "$VG_NAME"
  mkfs.ext4 "/dev/$VG_NAME/$LV_APP"
fi

if ! lvdisplay "/dev/$VG_NAME/$LV_DB" &>/dev/null; then
  echo "Creating logical volume $LV_DB..."
  lvcreate -L "$SIZE_DB" -n "$LV_DB" "$VG_NAME"
  mkfs.ext4 "/dev/$VG_NAME/$LV_DB"
fi

# Create mount points
mkdir -p "$MOUNT_APP" "$MOUNT_DB"

# Mount the volumes
mount | grep "$MOUNT_APP" >/dev/null || mount "/dev/$VG_NAME/$LV_APP" "$MOUNT_APP"
mount | grep "$MOUNT_DB" >/dev/null || mount "/dev/$VG_NAME/$LV_DB" "$MOUNT_DB"

# Add to fstab if not already there
grep -q "$MOUNT_APP" /etc/fstab || echo "/dev/$VG_NAME/$LV_APP $MOUNT_APP ext4 defaults 0 2" >> /etc/fstab
grep -q "$MOUNT_DB" /etc/fstab || echo "/dev/$VG_NAME/$LV_DB $MOUNT_DB ext4 defaults 0 2" >> /etc/fstab

echo "LVM setup complete!"
