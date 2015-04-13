# heim-deps

This repository contains production dependencies for Euphoria. It's intended to
serve as an audit log for third-party software used by our servers.

## Setting up deps for development

Heim's docker-compose.yml is set up to use deps stored in `deps/godeps` and
`deps/node_modules`. To link those paths to a heim-deps repo:

    ./deps.sh link ./path/to/heim/repo

## Adding new deps / updating

To fetch deps, run:

    ./deps.sh update ./path/to/heim/repo

This will download golang and nodejs deps into the repository. When the process
is completed, the versions of go and node/npm will be printed along with the
date. It's helpful to include these lines in your commit message when checking
in new deps.
