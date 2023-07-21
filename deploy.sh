#!/bin/bash

set -eu

echo "** deploy starts\n"
git branch -D gh-pages || true
git checkout -b gh-pages
cp -rf ./static/* ./
echo "** add changes\n"
git add ./* || true
git add -f ./dist || true
git commit -m "deploy"
echo "** push to gh-pages\n"
git push --force deploy gh-pages
git checkout master
echo "** deploy succeeded\n"
