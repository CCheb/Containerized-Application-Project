#!/bin/bash

LOGFILE="/var/log/deploy.log"
DB_CONTAINER_NAME="containerized-application-project-db-1"  # Match docker-compose name
BACKUP_FILE="/home/ubuntu/mysql_backup.sql"

echo "Deployment started at $(date)" | tee -a "$LOGFILE"

cd /home/ubuntu/Containerized-Application-Project || exit

# Backup existing database if container is running
if docker ps --format '{{.Names}}' | grep -q "$DB_CONTAINER_NAME"; then
  echo "Backing up MySQL database..." | tee -a "$LOGFILE"
  docker exec "$DB_CONTAINER_NAME" \
    sh -c 'exec mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' > "$BACKUP_FILE"
fi

# Restart Docker containers
echo "Restarting Docker stack..." | tee -a "$LOGFILE"
docker-compose down | tee -a "$LOGFILE"
docker-compose up -d --build --scale app=3 | tee -a "$LOGFILE"

# Restore database if backup exists and container is up
if [ -f "$BACKUP_FILE" ]; then
  echo "Restoring MySQL backup..." | tee -a "$LOGFILE"
  sleep 10  # Wait for MySQL to initialize
  docker exec -i "$DB_CONTAINER_NAME" \
    sh -c 'exec mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' < "$BACKUP_FILE"
fi

echo "Deployment completed at $(date)" | tee -a "$LOGFILE"
