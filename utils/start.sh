#!/bin/sh
docker container prune -f
docker network prune -f
docker-compose up -d