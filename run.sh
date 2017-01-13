#!/bin/bash
set -e
cd deploy
docker-compose --file=dev.yml build
docker-compose --file=dev.yml up
