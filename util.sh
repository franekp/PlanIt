function copy_to_host_if_changed {
  # copy_to_host_if_changed service-name src dest
  # service-name - name of service as in docker-compose.yml files
  # src - absolute file path in image
  # dest - file path in host
  IMG="${COMPOSE_PROJECT_NAME}_$1:latest"
  SRC=$2
  DEST=$3
  TEMP=`mktemp`
  trap "rm -f $TEMP; exit" HUP INT TERM EXIT
  docker run --rm --entrypoint cat $IMG $SRC > $TEMP
  if ! diff -q $DEST $TEMP > /dev/null  2>&1; then
    echo "Updating $DEST file"
    cp $TEMP $DEST
  else
    echo "No changes to $DEST during build"
  fi
  rm $TEMP
  trap - HUP INT TERM EXIT
}

function copy_to_host_if_changed_bug {
  # copy_to_host_if_changed service-name src dest
  # service-name - name of service as in docker-compose.yml files
  # src - absolute file path in image
  # dest - file path in host
  SERVICE=$1
  SRC=$2
  DEST=$3
  TEMP=`mktemp`
  #trap "rm -f $TEMP; exit" HUP INT TERM EXIT
  docker-compose run --rm --no-deps --entrypoint cat $SERVICE $SRC > $TEMP
  if ! diff -q $DEST $TEMP > /dev/null  2>&1; then
    echo "Updating $DEST file"
    cp $TEMP $DEST
  fi
  echo "yarn.lock temp file: $TEMP"
  #rm $TEMP
  #trap - HUP INT TERM EXIT
}
