#!/bin/bash

# This is a simplified version of kms-build-run.sh to
# create a release build of KMS in MSYS2.
# All components are directly installed into the MingW
# hierarchy!

# exit on error
set -e

SCRIPT_DIR=${0%/*}
KMS_MAIN_DIR=$SCRIPT_DIR/..
KMS_BUILD_DIR=$KMS_MAIN_DIR/build

# use all available processors for compilation
export MAKEFLAGS="-j$(nproc)"
# tell CMake to generate makefiles for MSYS
export CMAKE_GENERATOR="MSYS Makefiles"
export CMAKE_BUILD_TYPE=Release
export CMAKE_INSTALL_PREFIX=$MINGW_PREFIX
# get CMake version as MAJOR.MINOR as CMake modules
# are stored in that directory
CMAKEVERSION=$(cmake --version | egrep -o '[0-9]\.[0-9]+')


# creates the target build directory
# Parameter: module name
function enter_build_dir()
{
    local module=$1
    mkdir -p "$KMS_BUILD_DIR"/$module
    pushd "$KMS_BUILD_DIR"/$module
}

# kms-jsonrpc requires a specific kmsjsoncpp
enter_build_dir jsoncpp
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
      -DBUILD_STATIC_LIBS=ON \
      -DBUILD_SHARED_LIBS=OFF \
      ../../jsoncpp
make
make install
popd


pushd libuuid
if [ ! -f "$CMAKE_INSTALL_PREFIX/lib/libuuid.a" ]; then
  # libtool in the package is outdated and generates
  # version mismatches
  cp -f /mingw64/share/libtool/build-aux/ltmain.sh .
  ./configure --with-sysroot=/mingw64 --with-pic=no --enable-shared=no
  make
  make install
fi
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
cp scripts/kurento-module-creator "$CMAKE_INSTALL_PREFIX"/bin/
cp target/kurento-module-creator-jar-with-dependencies.jar "$CMAKE_INSTALL_PREFIX"/bin/
cp target/classes/FindKurentoModuleCreator.cmake "$CMAKE_INSTALL_PREFIX"/share/cmake-$CMAKEVERSION/Modules/
popd


# kms-jsonrpc
enter_build_dir kms-jsonrpc
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
      ../../kms-jsonrpc
make
make install
popd


cat <<EOF

**********************************************************
Yep, that's it so far.
Many more repos to compile, but these are not ready yet.
Please try again later ...
EOF