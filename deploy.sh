#!/bin/bash
# This is a Bash shell script to use with [Travis Continuous Integration](https://travis-ci.org)
# It will build your project as you will configure Travis CI, and if there will be any changes, it will push them into your repository as a commit. Basically, this script will push any added or removed files by your build process.
# For example: if you update `some-script.js`, you want to minify it and push as `some-script.min.js`. Travis CI can launch your build script on it's own server just after you push `some-script.js` and then it will push updated `some-script.min.js`.
# To use it, you have to authenticate on Travis CI and enable Continuous Integration for this project, then open settings and add some environment variables to allow Travis CI to push into your repository:
# `GIT_HOST` – server hostname, `github.com` by default
# `GIT_USER` – username
# `GIT_PASSWORD` – password
# Don't worry, [you can trust Travis](https://docs.travis-ci.com/user/environment-variables/#Defining-Variables-in-Repository-Settings)
# Also, you have to add `.travis.yml` file with this:

# script:
#  - bash ./build.sh #for example
#  - bash ./deploy.sh

# Configuring Travis CI [is not hard](https://docs.travis-ci.com/user/getting-started/), just few lines and you are a pilot!

# I am using some Travis environment variables like `TRAVIS` or `TRAVIS_COMMIT` here, you can look their output in [Travis CI Documentation](https://docs.travis-ci.com/user/environment-variables/#Default-Environment-Variables)

set -e # Exit with nonzero exit code if anything fails
if [ ! "$TRAVIS" ]; then
	# This script should work only on Travis CI server
	# Remove this code if you want to debug this script
	exit 0
fi
# Pull requests shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Should not deploy pull request; exiting."
    exit 0
fi
# Check if there are changes generated by build:
if [[ `git status --porcelain` ]]; then
	echo "There are changes to publish!"
	git status
	# Add any changes to index
	git add .
	SETTINGS_URL="https://travis-ci.org/${TRAVIS_REPO_SLUG}/settings"
	if [ ! "$GIT_USER" ]; then
		echo "Cannot push without git credentials: no user provided; set up GIT_USER environment variable in Travis CI project settings: ${SETTINGS_URL}"
		# There is no reason to continue deploy without push – the target action of this script
		exit 0
	fi
	if [ ! "$GIT_PASSWORD" ]; then
		echo "Cannot push without git credentials: no password provided; set up GIT_PASSWORD environment variable in Travis CI project settings: ${SETTINGS_URL}"
		# There is no reason to continue deploy without push – the target action of this script
		exit 0
	fi
	if [ ! "$GIT_HOST" ]; then
		echo "Cannot push without git credentials: no host provided; using GitHub.com as a default."
		echo "You can set up GIT_HOST environment variable in Travis CI project settings: ${SETTINGS_URL}"
		# You can skip defining this variable if your project are hosted on GitHub.com
		GIT_HOST="github.com"
	fi
	if [ ! "$SOURCE_BRANCH" ]; then
		echo "You are not provided a source git branch; using 'master' as a default."
		echo "You can set up SOURCE_BRANCH environment variable in Travis CI project settings: ${SETTINGS_URL}"
		# You can skip defining this variable if you want to deploy from master branch
		SOURCE_BRANCH=$TRAVIS_BRANCH # the branch
	fi
	if [ ! "$TARGET_BRANCH" ]; then
		echo "You are not provided a target git branch; using 'master' as a default."
		echo "You can set up TARGET_BRANCH environment variable in Travis CI project settings: ${SETTINGS_URL}"
		# You can skip defining this variable if you want to deploy to master branch
		# TODO: add specific behaviour if SOURCE_BRANCH != TARGET_BRANCH (gh-pages for example)
		TARGET_BRANCH=$TRAVIS_BRANCH # the branch
	fi
	# Build HTTPS git remote from Travis CI project environment variables
	git remote add deployment https://${GIT_USER}:${GIT_PASSWORD}@${GIT_HOST}/${TRAVIS_REPO_SLUG}.git
	# Tell everyone that this changes is pushed by Travis CI:
	git config user.name "Travis CI"
	# Author email will contain server address where this build done and looks like [this](travis@testing-worker-linux-docker-c84a3a30-3437-linux-5.prod.travis-ci.org)
	# Add `[skip ci]` to commit message to not start Travis CI build from push of this deployment commit
	git commit -m "Travis CI $TRAVIS_COMMIT [skip ci]"
	git push -u deployment ${TARGET_BRANCH}
# If no changes generated by build:
else
	echo "No changes to the output on this push; exiting."
    exit 0
fi
# I am scripting in Bash for the first time. Many thanks to [Domenic Denicola](https://github.com/domenic) for his [GitHub Pages publish script](https://gist.github.com/domenic/ec8b0fc8ab45f39403dd).
