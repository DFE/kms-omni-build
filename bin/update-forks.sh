#!/usr/bin/env bash

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

