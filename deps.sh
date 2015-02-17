#!/bin/bash
abspath() { cd $(dirname $1); echo $(pwd)/$(basename $1); }

usage="USAGE: $0 (sync|update) <heim-dir>"

sync_deps() {
  rsync -rlt --delete $SRCDIR/node_modules $HEIMDIR/client
}

update_js_deps() {
  cp $HEIMDIR/client/package.json ./

  npm install

  # a few hacks to reduce footprint...

  # remove tests
  find -name test -type d -print0 | xargs -0 rm -r

  # merge devDependencies into dependencies so `npm dedupe` considers them.
  perl -0777 -i.original -pe 's/\n  },\n  "devDependencies": {\n/,\n/igs' package.json
  for d in node_modules/*; do pushd $d; npm dedupe; popd; done
  npm dedupe

  rm package.json package.json.original
}

update_go_deps() {
  mkdir -p godeps/src go/src
  ln -sf $HEIMDIR go/src

  GOPATH=`pwd`/godeps:`pwd`/go go get -d heim/cmd/heimlich heim/cmd/heim-backend

  # jank alert: retain the git information but not create submodules.
  find godeps -depth -name .git -type d -execdir mv .git git \;

  rm -rf go
}

print_versions() {
  set +x
  echo "node `node -v`; npm `npm -v`"
  go version
  date
}

if [[ "$1" = "" || "$2" = "" ]]; then
  echo $usage
  exit 1
fi

SRCDIR=$(dirname `abspath $0`)
HEIMDIR=$(abspath $2)

cd $SRCDIR
set -x

case $1 in
  sync)
    sync_deps
    ;;
  update-go)
    update_go_deps
    ;;
  update-js)
    update_js_deps
    ;;
  update)
    update_go_deps
    update_js_deps
    print_versions
    ;;
  *)
    echo $usage
    exit 1
esac
