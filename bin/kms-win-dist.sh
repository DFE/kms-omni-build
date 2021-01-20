#!/bin/bash

# exit on error
set -e

if [ -z "$MINGW_PREFIX" ]
then
	echo -e "\e[31mError: \$MINGW_PREFIX is not set\e[0m"
	exit 1
fi

# Root directory where to store the entire package
DIST="$HOMEPATH/Desktop/Kurento"
# Temporary files to find dependencies
DEPS_FILE="$DIST/.deps"
TMP_DEPS_FILE="$DIST/.depstmp"
COLLECT_DEPS_FILE="$DIST/.depscoll"

# Binaries, libraries, configurations of Kurento
readarray -t KURENTO_BIN <<< "$(ls -1 "$MINGW_PREFIX"/bin/{libkms*.dll,libwebrtcdataproto.dll,kurento*,libjsonrpc.dll})"
readarray -t KURENTO_MODULES <<< "$(ls -1 "$MINGW_PREFIX"/lib/kurento/modules/*)"
# GStreamer plugins
readarray -t GST_PLUGINS <<< "$(ls -1 "$MINGW_PREFIX"/lib/gstreamer-1.0/*.dll)"

echo -e "\e[36m Creating target directories\e[0m"
mkdir -p \
    "$DIST/bin/" \
    "$DIST/etc/kurento/modules/kurento/" \
    "$DIST/lib/gstreamer-1.0/" \
    "$DIST/lib/kurento/modules/" \
    "$DIST/share/gstreamer-1.0/presets/" \
    "$DIST/share/kurento/"

echo -e "\e[36m Copying Kurento build\e[0m"
cp -f "${KURENTO_BIN[@]}" "$DIST/bin/"
cp -f "${KURENTO_MODULES[@]}" "$DIST/lib/kurento/modules/"
cp -f "${GST_PLUGINS[@]}" "$DIST/lib/gstreamer-1.0/"
cp -fr "$MINGW_PREFIX"/etc/kurento/* "$DIST"/etc/kurento/
cp -fr "$MINGW_PREFIX"/share/kurento/* "$DIST/share/kurento/"

echo -e "\e[36m Copying GStreamer presets\e[0m"
cp -f "$MINGW_PREFIX"/share/gstreamer-1.0/presets/* "$DIST/share/gstreamer-1.0/presets/"

rm -f "$DEPS_FILE" "$TMP_DEPS_FILE" "$COLLECT_DEPS_FILE"

# Params: list of files to get dependencies of
# Returns: unsorted dependencies in "$COLLECT_DEPS_FILE"
function get_dependencies() {
    for i in "$@"; do
        # Store dependencies of MSYS libraries. We do not
        # care for Windows system libraries. Ignore errors
        # here as the initial arrays also contain scripts and
        # configuration files.
        ldd "$i" 2> /dev/null | egrep -o "$MINGW_PREFIX/.*\.dll" >> "$COLLECT_DEPS_FILE" || true
    done
}

# Finds dependencies of the dependencies we have so far.
# Input : $COLLECT_DEPS_FILE
# Output: $TMP_DEPS_FILE (sorted)
function update_dependencies() {
    rm -f "$COLLECT_DEPS_FILE"
    get_dependencies $(cat "$DEPS_FILE")
    sort -u "$COLLECT_DEPS_FILE" "$DEPS_FILE" > "$TMP_DEPS_FILE"
}

echo -e "\e[36m Calculating direct dependencies\e[0m"
get_dependencies "${KURENTO_BIN[@]}"
get_dependencies "${KURENTO_MODULES[@]}"
get_dependencies "${GST_PLUGINS[@]}"
sort -u "$COLLECT_DEPS_FILE" > "$DEPS_FILE"

echo -e "\e[36m Calculating sub-dependencies\e[0m"
update_dependencies

# Make sure we have really everything
until cmp -s "$TMP_DEPS_FILE" "$DEPS_FILE"; do
    echo Next iteration ...
    mv -f "$TMP_DEPS_FILE" "$DEPS_FILE"
    update_dependencies
done

echo -e "\e[36m Copying dependencies\e[0m"
cp -u $(cat "$DEPS_FILE") "$DIST/bin/"
rm -f "$DEPS_FILE" "$TMP_DEPS_FILE" "$COLLECT_DEPS_FILE"

echo Installed in $DIST
