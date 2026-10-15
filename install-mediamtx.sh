#!/usr/bin/env bash

# Download MediaMTX and install it as a systemd service on port 8554.
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

if [ "$(uname -m)" != "aarch64" ]; then
    echo "This script installs the arm64 MediaMTX build. uname -m is $(uname -m)."
    exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$ROOT/mediamtx"
VERSION="v1.15.3"
TARBALL="mediamtx_${VERSION}_linux_arm64.tar.gz"
URL="https://github.com/bluenviron/mediamtx/releases/download/${VERSION}/${TARBALL}"

mkdir -p "$WORKDIR"
wget -O "$WORKDIR/$TARBALL" "$URL"
tar -xzf "$WORKDIR/$TARBALL" -C "$WORKDIR"

install -m 755 "$WORKDIR/mediamtx" /usr/local/bin/mediamtx
mkdir -p /usr/local/etc
cp "$ROOT/mediamtx.yml" /usr/local/etc/mediamtx.yml
cp "$ROOT/mediamtx.service" /etc/systemd/system/mediamtx.service

systemctl daemon-reload
systemctl enable --now mediamtx.service

echo "MediaMTX is installed and running."
echo "Check status: systemctl status mediamtx"
echo "It should be listening on port 8554."
