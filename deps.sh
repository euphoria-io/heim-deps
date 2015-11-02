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

update_go_deps() {
  rm -rf godeps
  mkdir -p godeps/src/euphoria.io
  cp -r $HEIMDIR/ godeps/src/euphoria.io/heim

  GOPATH=`pwd`/godeps go get -d -t -x ./godeps/src/euphoria.io/heim/... github.com/coreos/etcd

  # pin go-etcd to v0.4.6 (until coreos upgrades to etcd 2.0)
  git --git-dir=godeps/src/github.com/coreos/go-etcd/.git \
      --work-tree=godeps/src/github.com/coreos/go-etcd \
      checkout 6aa2da5

  # save the commit hash of deps but remove the git metadata so we don't create submodules.
  find godeps -depth -name .git -type d -execdir sh -c "git rev-parse HEAD > git-HEAD && rm -rf .git" \;

  # and likewise for hg repos
  find godeps -depth -name .hg -type d -execdir sh -c "hg parent -T '{node}\n' > hg-HEAD && rm -rf .hg" \;

  rm -rf godeps/src/euphoria.io/heim
}

print_go_versions() {
  set +x
  go version
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
  update-go)
    update_go_deps
    print_go_versions
    date
    ;;
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
    update_go_deps
    update_js_deps
    print_go_versions
    print_js_versions
    date
    ;;
  *)
    echo $usage
    exit 1
esac
