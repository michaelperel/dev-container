#!/bin/bash

set -euo pipefail

tmp="$(mktemp -d)"

function cleanup {
	rm -rf "${tmp}"
}

trap cleanup EXIT

# https://pkg.go.dev/golang.org/dl/gotip
cd "${tmp}"
go install golang.org/dl/gotip@latest
gotip download
echo 'export GOROOT=$(gotip env GOROOT)' >> "${HOME}/.bashrc"
echo 'alias go=gotip' >> "${HOME}/.bashrc"

# https://github.com/golang/tools/blob/master/gopls/doc/advanced.md
gotip mod init gopls-unstable
gotip get golang.org/x/tools/gopls@master golang.org/x/tools@master
gotip install golang.org/x/tools/gopls

echo "run source ${HOME}/.bashrc for the go command to alias to gotip"
