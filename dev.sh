#!/bin/bash
set -e
set -u

cd `dirname "$0"`  # make sure we are in project root
source util.sh

mkdir -p build
mkdir -p build/css
mkdir -p build/html
mkdir -p build/js

export COMPOSE_PROJECT_NAME="planitdev"
export COMPOSE_FILE="containers/dev.yml"

# build all containers, thanks to the use of docker volumes, the separate
# "build frontend" step is not needed
docker-compose build
# copy updated yarn.lock and requirements.txt back to host
copy_to_host_if_changed frontend /frontend/yarn.lock src/frontend/yarn.lock
copy_to_host_if_changed web /web/requirements.txt src/web/requirements.txt
copy_to_host_if_changed worker /worker/requirements.txt src/worker/requirements.txt

# run services with live code reload (docker volumes + "watch")
# - django code reload: `./manage.py runserver` handles that
# - a container is running that watches frontend files (sass and elm)
#   and compiles them as they change; compiled files are in "build" directory
docker-compose up
