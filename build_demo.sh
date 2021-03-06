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

# compile frontend (we have to do it before if not using docker volumes)
# use dev compose file since we don't really have this machine in production,
# it only is needed for compilation
# TODO fix this! - should be separate thing to not mount any directories (???)
docker-compose --file=containers/dev.yml build frontend
docker-compose --file=containers/dev.yml run --no-deps --rm frontend yarn install
docker-compose --file=containers/dev.yml run --no-deps --rm frontend elm-package install --yes
docker-compose --file=containers/dev.yml run --no-deps --rm frontend yarn run build  # build javascript, html and css
docker-compose --file=containers/dev.yml run --no-deps --rm frontend yarn run minify  # minify javascript, html and css

# build other containers - particularly nginx, which depends on files the above
# commands has written to <project root>/build/
docker-compose build
# do not copy updated yarn.lock and requirements.txt back to host, dev mode
# is for this stuff
