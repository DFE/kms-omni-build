#!/usr/bin/env bash

# Install all utilities and libraries in the MSYS2
# environment to enable building Kurento on Windows.

# exit on error
set -e

# required for the Kurento Module Creator
# Note: If you have a JDK and Apache Maven already installed
#       as regular packages on Windows, then you can skip this
#       and simply add the paths similar to the setup at the
#       end of the script. But beware that newer JDKs have
#       not been tested.
#
# WARNING: The JDK and Maven versions in this script may be
#          outdated and contain security issues already
#          fixed in newer versions. These are only used
#          for building Kurento Media Server.
#          They are NOT bundled with it!
#
#          DO NOT ADD THESE TO THE REGULAR Windows PATH!!!
#
JDK_VERSION=8u242-b08
JDK_PKG=OpenJDK8U-jdk_x64_windows_hotspot_8u242b08.zip
JDK_DIR=jdk$JDK_VERSION

MAVEN_VERSION=3.6.3
MAVEN_PKG=apache-maven-$MAVEN_VERSION-bin.zip
MAVEN_DIR=apache-maven-$MAVEN_VERSION

# install essential tools
pacman -S --noconfirm --needed \
	base-devel \
	$MINGW_PACKAGE_PREFIX-cmake \
	$MINGW_PACKAGE_PREFIX-toolchain

# install libraries for Kurento
pacman -S --noconfirm --needed \
	$MINGW_PACKAGE_PREFIX-gst-libav \
	$MINGW_PACKAGE_PREFIX-gst-plugins-bad \
	$MINGW_PACKAGE_PREFIX-gst-plugins-base \
	$MINGW_PACKAGE_PREFIX-gst-plugins-good \
	$MINGW_PACKAGE_PREFIX-gst-plugins-ugly \
	$MINGW_PACKAGE_PREFIX-gstreamer \
	$MINGW_PACKAGE_PREFIX-SDL

# install OpenJDK for Kurento Module Creator
wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/$JDK_DIR/$JDK_PKG
unzip $JDK_PKG -d /opt/
echo "export JAVA_PATH=/opt/$JDK_DIR" >> ~/.bashrc
echo "export PATH=\$PATH:/opt/$JDK_DIR/bin" >> ~/.bashrc

# install Apache Maven Kurento Module Creator
wget https://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/$MAVEN_PKG
unzip $MAVEN_PKG -d /opt/
echo "export PATH=\$PATH:/opt/$MAVEN_DIR/bin" >> ~/.bashrc

# setup for CMake
echo 'export CMAKE_GENERATOR="MSYS Makefiles"' >> ~/.bashrc
# tell Make to use all available processors
echo 'export MAKEFLAGS="-j$(nproc)"' >> ~/.bashrc


# kms-jsonrpc requires kmsjsoncpp, the regular jsoncpp
# is for some reason not accepted
source ~/.bashrc
DIRNAME=${0%/*}
pushd "$DIRNAME/.."
git clone https://github.com/Kurento/jsoncpp.git
mkdir -p build/jsoncpp
cd build/jsoncpp
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$MINGW_PREFIX -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF ../../jsoncpp
make
make install
popd


echo -e "\033[0;31mReopen console to update environment or source ~/.bashrc\033[0m"
