#!/bin/sh
set -eu

echo "== Build demo artifact =="

version=$(cat app/version.txt)
sha=${CI_COMMIT_SHORT_SHA:-local}
mkdir -p preview

cat > preview/release.txt <<RELEASE
version=$version
sha=$sha
artifact=demo-app-$version-$sha
RELEASE

echo "Build artifact created: preview/release.txt"
cat preview/release.txt
