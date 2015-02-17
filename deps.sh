#!/bin/bash
abspath() { cd $(dirname $1); echo $(pwd)/$(basename $1); }

usage="USAGE: $0 (sync|update) <heim-dir>"
SRCDIR=$(dirname `abspath $0`)

sync_deps() {
  set -x
  rsync -rlt --delete $SRCDIR/node_modules $1/client
}

update_deps() {
  cd $SRCDIR
  set -x
  cp $1/client/package.json ./

  npm install

  # a few hacks to reduce footprint...

  # remove tests
  find -name test -type d -print0 | xargs -0 rm -r

  # merge devDependencies into dependencies so `npm dedupe` considers them.
  perl -0777 -i.original -pe 's/\n  },\n  "devDependencies": {\n/,\n/igs' package.json
  for d in node_modules/*; do pushd $d; npm dedupe; popd; done
  npm dedupe

  rm package.json package.json.original

  git status
  echo "node `node -v`; npm `npm -v`; `date`"
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
