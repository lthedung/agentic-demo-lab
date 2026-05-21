#!/bin/sh
set -eu

echo "== Validate demo application =="

if [ ! -f app/version.txt ]; then
  echo "app/version.txt is missing"
  exit 1
fi

version=$(cat app/version.txt)

if [ -z "$version" ]; then
  echo "app/version.txt is empty"
  exit 1
fi

echo "Version file found: $version"
echo "Lint simulation passed"
echo "Unit test simulation passed"
