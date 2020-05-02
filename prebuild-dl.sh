#!/bin/bash

BASE_URL=https://github.com/nswa-project/buildbot/releases/download/prebuild-assets/prebuild-

cd "$2"

rm -rf build_dir staging_dir

wget -O _.tar.gz "${BASE_URL}${1}.tar.gz" || exit 1
tar xzf _.tar.gz || exit 1
rm -f _.tar.gz
