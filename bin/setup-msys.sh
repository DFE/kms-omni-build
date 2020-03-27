#!/usr/bin/env bash

# Exit on error
set -e

JDK_VERSION=8u242b08
JDK_PKG=OpenJDK8U-jdk_x64_windows_hotspot_$JDK_VERSION.zip
JDK_DIR=$JDK_VERSION

MAVEN_VERSION=3.6.3
MAVEN_PKG=apache-maven-$MAVEN_VERSION-bin.zip
MAVEN_DIR=apache-maven-$MAVEN_VERSION

# install OpenJDK for Kurento Module Creator
wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/$JDK_VERSION/$JDK_PKG
unzip $JDK_PKG -d /opt/
echo "export JAVA_PATH=/opt/$JDK_DIR" >> ~/.bashrc
echo "export PATH=\$PATH:/opt/$JDK_DIR/bin" >> ~/.bashrc

# install Apache Maven Kurento Module Creator
wget https://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/$MAVEN_PKG
unzip $MAVEN_PKG -d /opt/
echo "export PATH=\$PATH:/opt/$MAVEN_DIR/bin" >> ~/.bashrc

