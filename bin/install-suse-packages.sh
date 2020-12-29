#!/bin/bash

# Install required packages for Tumbleweed.
# This may also work for OpenSUSE Leap 15.2 once it is available.
# OpenSUSE Leap 15.1 is missing some libraries.

# Package maven contains the mvn app required for
# Kurento Module Maker.

sudo zypper install \
	 glibmm2_4-devel \
	 gstreamer-devel \
	 gstreamer-plugins-bad-devel \
	 gstreamer-plugins-base-devel \
	 gstreamer-plugins-good-extra \
	 gstreamer-plugins-libav \
	 gstreamer-plugins-ugly \
	 gstreamer-plugins-vaapi \
	 gstreamer-rtsp-server-devel \
	 libnice-devel \
	 libboost_filesystem-devel \
	 libboost_log-devel \
	 libboost_program_options-devel \
	 libboost_system-devel \
	 libboost_test-devel \
	 libboost_thread-devel \
	 libevent-devel \
	 libsigc++2-devel \
	 libsoup-devel \
	 libvpx-devel \
	 maven

# Only install Java, it is not already there.
# Not sure though, if the Kurento Module Maker also
# works with Java 15. Tests with Java 8 were successful.
if ! type java; then
	sudo zypper install java-1_8_0-openjdk
fi
