#!/bin/bash
set -e
mkdir -p build
cd containers
docker-compose --file=dev.yml build
docker-compose --file=dev.yml up
