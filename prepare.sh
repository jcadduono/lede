#!/bin/bash

abort() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

[ -d staging_dir ] || ./update.sh

echo "...make defconfig..."
[ "$1" ] && DEVICE=$1
[ "$DEVICE" ] || DEVICE=r7800

[ -f ".config.$DEVICE" ] || abort "No init config found for $DEVICE"
cp ".config.$DEVICE" .config
echo "...configuring for device: $DEVICE..."
make defconfig

echo "...cleanup..."
rm -rf build_dir staging_dir tmp
make clean

echo "...download new source packages..."
make -j4 download || abort "Download source packages failed"

mkdir -p logs
