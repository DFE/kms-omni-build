#!/usr/bin/env bash

# TEMPORARY - Update the DResearch Kurento forks and also
#             the original ("upstream") Kurento repositories.
# This will be no longer needed once merged into the
# original repositories.

# exit on failure
set -e

DIRNAME=${0%/*}

cd "$DIRNAME/.."

SUBMODULES=$(grep submodule .gitmodules | grep -v kms-filters | awk -F\" '{ print $2 }')

for sm in . $SUBMODULES
do
	pushd $sm
	git pull
	git fetch upstream
	popd
done

