#!/bin/sh
set -eu

echo "== Deploy to staging environment =="

version=$(cat app/version.txt)
sha=${CI_COMMIT_SHORT_SHA:-local}
mkdir -p preview

cat > preview/staging-release.txt <<RELEASE
environment=staging
version=$version
sha=$sha
RELEASE

echo "Staging deployment simulation completed"
cat preview/staging-release.txt
