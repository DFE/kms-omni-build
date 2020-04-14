#!/bin/bash

# DOES NOT WORK for kms-elements!
# Need to wait for Leap 15.2 for new GStreamer.

# This is a simplified version of kms-build-run.sh to
# create a release build of KMS on OpenSUSE. This was
# tested on Leap 15.1. Be aware that you need quite
# a bunch to be installed via yast or zypper. You will
# see the according errors, if you missed something ...

# exit on error
set -e

SCRIPT_DIR=${0%/*}
KMS_MAIN_DIR=$SCRIPT_DIR/..
KMS_BUILD_DIR=$KMS_MAIN_DIR/build

# use all available processors for compilation
export MAKEFLAGS="-j$(nproc)"
# tell CMake to generate makefiles for MSYS
CMAKE_BUILD_TYPE=Release
CMAKE_INSTALL_PREFIX=$HOME/kurento
# get CMake version as MAJOR.MINOR as CMake modules
# are stored in that directory
CMAKEVERSION=$(cmake --version | egrep -o '[0-9]\.[0-9]+')
CMAKE_MODULE_PATH="$CMAKE_INSTALL_PREFIX"/share/cmake-$CMAKEVERSION/Modules


# creates the target build directory
# Parameter: module name
function enter_build_dir()
{
    local module=$1
    mkdir -p "$KMS_BUILD_DIR"/$module
    pushd "$KMS_BUILD_DIR"/$module
}


pushd "$KMS_MAIN_DIR"

# kms-jsonrpc requires kmsjsoncpp, the regular jsoncpp
# is for some reason not accepted
if [ ! -d jsoncpp ]; then
    git clone https://github.com/Kurento/jsoncpp.git
fi


# libwebsocketpp is required for kurento-media-server
# master branch does not compile with newer Boost versions,
# need to use develop branch that contains an appropriate patch
if [ ! -d websocketpp ]; then
    git clone -b develop https://github.com/zaphoyd/websocketpp
fi

popd


# kms-jsonrpc requires a specific kmsjsoncpp
enter_build_dir jsoncpp
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
      -DBUILD_STATIC_LIBS=OFF \
      -DBUILD_SHARED_LIBS=ON \
      ../../jsoncpp
make
make install
popd


# kms-cmake-utils
enter_build_dir kms-cmake-utils
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
      ../../kms-cmake-utils
make
make install
popd


# kurento-module-creator
# Note: This is built in the source directory, not in
#       the build directory.
pushd kurento-module-creator
mvn package
mkdir -p "$CMAKE_INSTALL_PREFIX"/bin/
cp scripts/kurento-module-creator "$CMAKE_INSTALL_PREFIX"/bin/
cp target/kurento-module-creator-jar-with-dependencies.jar "$CMAKE_INSTALL_PREFIX"/bin/
cp target/classes/FindKurentoModuleCreator.cmake "$CMAKE_MODULE_PATH"
popd


# kms-jsonrpc
enter_build_dir kms-jsonrpc
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
      ../../kms-jsonrpc
make
make install
popd


# kms-core
enter_build_dir kms-core
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
      ../../kms-core
make
make install
popd


# websocketpp
# libwebsocketpp is required for kurento-media-server
enter_build_dir websocketpp
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DINSTALL_CMAKE_DIR="$CMAKE_MODULE_PATH" \
      ../../websocketpp
make
make install
ln -sf "$CMAKE_INSTALL_PREFIX"/include/websocketpp "$CMAKE_INSTALL_PREFIX"/include/kurento/websocketpp
popd


# kurento-media-server
enter_build_dir kurento-media-server
# Our websocketpp announces itself as 0.8.0.
sed -i 's/find_package(WEBSOCKETPP 0.7.0 REQUIRED)/find_package(WEBSOCKETPP REQUIRED)/g' ../../kurento-media-server/server/transport/websocket/CMakeLists.txt
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
	  -DWEBSOCKETPP_DIR="$CMAKE_MODULE_PATH" \
      ../../kurento-media-server
make
make install
popd


# kms-elements
enter_build_dir kms-elements
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
      -DKURENTO_MODULES_DIR=$CMAKE_INSTALL_PREFIX/share/kurento/modules/ \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
      ../../kms-elements
make
make install
popd

