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

# f*cking timestamp magic
if [ ! -f last_docker_build_timestamp ]; then
  echo 'Running docker build for the first time here.'
else
  echo 'Files changed since last docker build:'
fi
if [ ! -f last_docker_build_timestamp ] \
  || find containers -newer last_docker_build_timestamp | egrep '.*' \
  || find 'src/web/requirements.in' -newer last_docker_build_timestamp | egrep '.*' \
  || find src/web/requirements.txt -newer last_docker_build_timestamp | egrep '.*' \
  || find 'src/worker/requirements.in' -newer last_docker_build_timestamp | egrep '.*' \
  || find src/worker/requirements.txt -newer last_docker_build_timestamp | egrep '.*' \
; \
then
  # install system packages and python packages
  docker-compose build
  touch last_docker_build_timestamp
  # copy updated (by pip-compile) requirements.txt back to host
  copy_to_host_if_changed web /web/requirements.txt src/web/requirements.txt
  copy_to_host_if_changed worker /worker/requirements.txt src/worker/requirements.txt
else
  echo 'None such files.'
  echo 'Skipping docker build.'
fi

# f*cking timestamp magic
if [ ! -f last_yarn_install_timestamp ]; then
  echo 'Running yarn install for the first time here.'
else
  echo 'Files changed since last yarn install:'
fi
if [ ! -f last_yarn_install_timestamp ] \
  || find src/frontend/package.json -newer last_yarn_install_timestamp | egrep '.*' \
  || find src/frontend/elm-package.json -newer last_yarn_install_timestamp | egrep '.*' \
  || find src/frontend/yarn.lock -newer last_yarn_install_timestamp | egrep '.*' \
; \
then
  # install npm and elm packages
  find src/frontend/node_modules/* | grep -v sass | xargs rm -rf # clear node_modules/ but leave node-sass and gulp-sass
  # don't remove elm-stuff/ because elm-package does not have cache, but package versions
  # are included in folder names, so this should not be necessary anyway
  docker-compose --file=containers/dev.yml run --no-deps --rm frontend yarn install
  touch last_yarn_install_timestamp
else
  echo 'None such files.'
  echo 'Skipping yarn install.'
fi

# run services with live code reload (docker volumes + "watch")
# - django code reload: `./manage.py runserver` handles that
# - a container is running that watches frontend files (sass and elm)
#   and compiles them as they change; compiled files are in "build" directory
docker-compose up
