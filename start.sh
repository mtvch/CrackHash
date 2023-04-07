#!/bin/bash

docker compose up -d

sleep 10

docker exec mongo1 /scripts/rs-init.sh