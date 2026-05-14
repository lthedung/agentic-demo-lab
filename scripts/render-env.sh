#!/bin/sh
set -eu

environment="$1"
version="$2"
deploy_time="$3"
strategy="$4"
active_color="$5"
out_dir="$6"
state_file="$7"

mkdir -p "$out_dir"
mkdir -p "$(dirname "$state_file")"

sed \
  -e "s#__APP_NAME__#GitLab CI/CD Session 4 Demo#g" \
  -e "s#__VERSION__#$version#g" \
  -e "s#__ENVIRONMENT__#$environment#g" \
  -e "s#__DEPLOY_TIME__#$deploy_time#g" \
  -e "s#__STRATEGY__#$strategy#g" \
  -e "s#__ACTIVE_COLOR__#$active_color#g" \
  app/index.html > "$out_dir/index.html"

cat > "$state_file" <<EOF
{
  "version": "$version",
  "environment": "$environment",
  "deployTime": "$deploy_time",
  "strategy": "$strategy",
  "activeColor": "$active_color"
}
EOF
