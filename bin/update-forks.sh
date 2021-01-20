#!/usr/bin/env bash

# TEMPORARY - Update the DResearch Kurento forks and also
#             the original ("upstream") Kurento repositories.
# This will be no longer needed once merged into the
# original repositories.

DIRNAME=${0%/*}

MAINDIR="$(realpath "$DIRNAME/..")"
cd "$MAINDIR"

SUBMODULES=$(grep submodule .gitmodules | awk -F\" '{ print $2 }')

for sm in . $SUBMODULES
do
	if [ -d $sm/.git ]; then
		echo Updating $sm
		cd $sm && \
		git pull && \
		git fetch upstream
		cd "$MAINDIR"
	fi
done

