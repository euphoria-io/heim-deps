#!/bin/bash
abspath() { cd $(dirname $1); echo $(pwd)/$(basename $1); }

usage="USAGE: $0 (update|update-go|update-js|compact-js) <heim-dir>"

update_js_deps() {
  cp $HEIMDIR/client/package.json ./

  npm install

  rm package.json
}

compact_js_deps() {
  cp $HEIMDIR/client/package.json ./

  # a few hacks to reduce footprint...

  # remove tests
  find -name test -type d -print0 | xargs -0 rm -r

  # merge devDependencies into dependencies so `npm dedupe` considers them.
  perl -0777 -i.original -pe 's/\n  },\n  "devDependencies": {\n/,\n/igs' package.json
  for d in node_modules/*; do pushd $d; npm dedupe; popd; done
  npm dedupe

  rm package.json package.json.original
}

print_js_versions() {
  set +x
  echo "node `node -v`; npm `npm -v`"
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
  update-js)
    update_js_deps
    print_js_versions
    date
    ;;
  compact-js)
    compact_js_deps
    print_js_versions
    date
    ;;
  update)
    update_js_deps
    print_js_versions
    date
    ;;
  *)
    echo $usage
    exit 1
esac
