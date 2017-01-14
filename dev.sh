#!/bin/bash
set -e
set -u

mkdir -p build
mkdir -p build/css
mkdir -p build/html
mkdir -p build/js

export COMPOSE_PROJECT_NAME="planitdev"
export COMPOSE_FILE="containers/dev.yml"

# make sure we are in project root
cd `dirname "$0"`

source util.sh

# compile frontend
docker-compose build frontend  # only installs build-time dependencies
copy_to_host_if_changed frontend /frontend/yarn.lock src/frontend/yarn.lock # copy updated yarn.lock back to host
docker-compose run --rm frontend yarn run build # build javascript, html and css

# build other containers
docker-compose build
copy_to_host_if_changed web /web/requirements.txt src/web/requirements.txt # copy updated requirements.txt back to host
copy_to_host_if_changed worker /worker/requirements.txt src/worker/requirements.txt # copy updated requirements.txt back to host

# run services with live code reload (docker volumes + "watch")
# - django code reload: `./manage.py runserver` handles that
# - a container is running that watches frontend files (sass and elm)
#   and compiles them as they change; compiled files are in "build" directory
docker-compose up
