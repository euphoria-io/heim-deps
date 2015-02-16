#!/bin/bash

abspath() { cd $(dirname $1); echo $(pwd)/$(basename $1); }

usage="USAGE: $0 (sync|update) <heim-dir>"
SRCDIR=$(dirname `abspath $0`)

sync_deps() {
  rsync -rult --delete $SRCDIR/node_modules $1/client
}

update_deps() {
  cd $SRCDIR
  cp $1/client/package.json ./
  npm install
  rm package.json
  git status
}

if [[ "$1" = "" || "$2" = "" ]]; then
  echo $usage
  exit 1
fi

case $1 in
  sync)
    sync_deps $2
    ;;
  update)
    update_deps $2
    ;;
  *)
    echo $usage
    exit 1
esac
