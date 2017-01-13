#!/bin/bash
set -e
cd docker
docker-compose --file=dev.yml build
docker-compose --file=dev.yml up
