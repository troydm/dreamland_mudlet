#!/bin/bash
set -e


SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Not on master, skipping deploy."
    exit 0
fi

REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`
echo "Repository: $REPO"
echo "SHA: $SHA"
ls -la

zip dl-new.zip Dreamland.xml config.lua
git clone $REPO gh-pages
cd gh-pages
git checkout gh-pages
mv ../dl-new.zip downloads/dl.zip
if git diff --quiet; then
    echo "No changes to zip file, skipping deploy."
    exit 0
fi

git config user.name "Travis CI"
git config user.email "ruffina.koza@gmail.com"
git add -A .
git commit -m "Deploy to GitHub Pages: ${SHA}"

#openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../deploy_key.enc -out ../deploy_key -d
chmod 600 ../deploy_key
eval `ssh-agent -s`
ssh-add ../deploy_key

git push $SSH_REPO $TARGET_BRANCH
