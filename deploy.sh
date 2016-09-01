#!/bin/bash
set -e # Exit with nonzero exit code if anything fails
function build {
    npm run gulp
}
git checkout master
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    build
    exit 0
fi
build
if [ -z `git diff --exit-code` ]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi
git add .
git remote add deployment https://$USER:$PASSWORD@github.com/Grawl/travis-learn.git
git config user.name "Travis CI"
git commit -m "Travis CI $TRAVIS_COMMIT"
git push -u deployment master
