#!/bin/bash

set -x

for package in $(lerna ls --parseable --since); do
  parsed=$(jq -s '.[0] * .[1]' "${package}/package.json" global-scripts.json)
  echo "${parsed}" > "${package}/package.json"
done
