#!/bin/bash
set -e

REPO="https://github.com/a573412261/lookin-cli.git"
INSTALL_DIR="/usr/local/bin"
TMPDIR=$(mktemp -d)

echo "=> Cloning lookin-cli..."
git clone --depth 1 "$REPO" "$TMPDIR/lookin-cli"

echo "=> Building..."
cd "$TMPDIR/lookin-cli"
swift build -c release

echo "=> Installing to $INSTALL_DIR ..."
cp .build/release/lookin-cli "$INSTALL_DIR/lookin-cli"

echo "=> Cleaning up..."
rm -rf "$TMPDIR"

echo "=> Done! Run: lookin-cli --help"
