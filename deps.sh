#!/bin/bash
abspath() { cd $(dirname $1); echo $(pwd)/$(basename $1); }

usage="USAGE: $0 (link|update) <heim-dir>"

link_deps() {
  mkdir -p $HEIMDIR/deps
  ln -s $SRCDIR/node_modules $HEIMDIR/deps/node_modules
  ln -s $SRCDIR/node_modules $HEIMDIR/client/node_modules
  ln -s $SRCDIR/godeps $HEIMDIR/deps/godeps
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
  rm -rf godeps
  mkdir -p godeps/src go/src
  cp -r $HEIMDIR go/src

  GOPATH=`pwd`/godeps:`pwd`/go go get -d -t heim/...

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
  link)
    link_deps
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
