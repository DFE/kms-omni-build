#!/usr/bin/env bash

# TEMPORARY - Retrieve the DResearch Kurento forks with the
#             same hierarchy like Kurento's kms-omni-build
# This will be no longer needed once merged into the
# original repositories.

# exit on failure
set -e

DIRNAME=${0%/*}

# main repo
git remote add upstream git@github.com:Kurento/kms-omni-build.git
git fetch upstream

cd "$DIRNAME/.."

# To avoid screwing up everything, we ignore the submodule setup of the original
# kms-omni-build and handle the forked repos ourselves with the same hierarchy.
# As kms-filters is not up-to-date yet, we ignore it for now.
SUBMODULES=$(grep submodule .gitmodules | grep -v kms-filters | awk -F\" '{ print $2 }')

for sm in $SUBMODULES
do
	git clone git@github.com:DFE/$sm.git
	pushd $sm
	git remote add upstream git@github.com:Kurento/$sm.git
	git fetch upstream
	popd
done

