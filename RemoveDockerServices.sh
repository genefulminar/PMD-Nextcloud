#!/bin/bash

# Remove all containers
echo "Removing all containers..."
docker rm -f $(docker ps -aq)

# Remove all networks
echo "Removing all networks..."
docker network rm $(docker network ls -q)

# Remove all volumes
echo "Removing all volumes..."
docker volume rm $(docker volume ls -q)

# Remove all images
echo "Removing all images..."
docker rmi -f $(docker images -aq)

echo "All Docker services have been removed."
