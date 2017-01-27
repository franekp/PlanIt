#!/bin/bash
set -e
set -u

cd `dirname "$0"`  # make sure we are in project root
source util.sh

mkdir -p build
mkdir -p build/css
mkdir -p build/js

export COMPOSE_PROJECT_NAME="planitdemo"
export COMPOSE_FILE="containers/demo.yml"

docker-compose up
