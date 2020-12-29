#!/bin/bash

# This script installs Kurento on Tumbleweed.
# OpenSUSE Leap 15.1 is missing some package for kms-elements.
# Need to wait for Leap 15.2 for new GStreamer.

# Be sure to run install-suse-packages.sh beforehands.

# exit on error
set -e

SCRIPT_DIR=${0%/*}
KMS_MAIN_DIR=$SCRIPT_DIR/..
KMS_BUILD_DIR=$KMS_MAIN_DIR/build

# use all available processors for compilation
export MAKEFLAGS="-j$(nproc)"

# Install into system directories. I invested quite some
# effort to make it also work in a private directory
# such as $HOME/kurento. But that would require quite some
# modifications to the CMakefiles.
CMAKE_INSTALL_PREFIX=/usr
# Release build
CMAKE_BUILD_TYPE=Release
# OpenSUSE puts files into "cmake" whereas *some* Kurento modules
# are using "cmake-<version>".
CMAKE_MODULE_PATH="$CMAKE_INSTALL_PREFIX/share/cmake/Modules"


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
# do not use the static libs or you end up in
# multiply defined functions
enter_build_dir jsoncpp
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
      -DBUILD_STATIC_LIBS=OFF \
      -DBUILD_SHARED_LIBS=ON \
      ../../jsoncpp
make
sudo make install
popd


# websocketpp
# libwebsocketpp is required for kurento-media-server
enter_build_dir websocketpp
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DINSTALL_CMAKE_DIR="$CMAKE_MODULE_PATH" \
      ../../websocketpp
make
sudo make install
popd


# kurento-module-creator
# Note: This is built in the source directory, not in
#       the build directory.
pushd kurento-module-creator
mvn package
mkdir -p "$CMAKE_INSTALL_PREFIX"/bin/
sudo cp scripts/kurento-module-creator "$CMAKE_INSTALL_PREFIX"/bin/
sudo cp target/kurento-module-creator-jar-with-dependencies.jar "$CMAKE_INSTALL_PREFIX"/bin/
sudo cp target/classes/FindKurentoModuleCreator.cmake "$CMAKE_MODULE_PATH"
popd


# So far we have now installed the prerequisites for Kurento.
# You can uncomment the exit line below and try it now with
# the regular kms-build-run.sh instead. Good luck!
# exit 0


# kms-cmake-utils
enter_build_dir kms-cmake-utils
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DCMAKE_MODULES_INSTALL_DIR="$CMAKE_MODULE_PATH" \
      ../../kms-cmake-utils
make
sudo make install
popd


# kms-jsonrpc
enter_build_dir kms-jsonrpc
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
	  -DCMAKE_MODULES_INSTALL_DIR="$CMAKE_MODULE_PATH" \
      ../../kms-jsonrpc
make
sudo make install
popd


# kms-core
enter_build_dir kms-core
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
	  -DCMAKE_MODULES_INSTALL_DIR="$CMAKE_MODULE_PATH" \
      ../../kms-core
make
sudo make install
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
sudo make install
popd


# kms-elements
enter_build_dir kms-elements
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
      -DKURENTO_MODULES_DIR=$CMAKE_INSTALL_PREFIX/share/kurento/modules/ \
	  -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" \
      ../../kms-elements
make
sudo make install
popd

