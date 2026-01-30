#!/usr/bin/env bash

INSTALL_DIR="$(pwd)/mediamtx"
mkdir -p $INSTALL_DIR
wget -P $INSTALL_DIR https://github.com/bluenviron/mediamtx/releases/download/v1.15.3/mediamtx_v1.15.3_linux_arm64.tar.gz
tar -xzf "$INSTALL_DIR/mediamtx_v1.15.3_linux_arm64.tar.gz" -C $INSTALL_DIR

