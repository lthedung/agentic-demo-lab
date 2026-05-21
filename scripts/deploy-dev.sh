#!/bin/sh
set -eu

echo "== Deploy to dev environment =="

version=$(cat app/version.txt)
sha=${CI_COMMIT_SHORT_SHA:-local}
mkdir -p preview

cat > preview/dev-release.txt <<RELEASE
environment=dev
version=$version
sha=$sha
RELEASE

echo "Dev deployment simulation completed"
cat preview/dev-release.txt
