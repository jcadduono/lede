#!/bin/bash

abort() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

echo "...cleanup..."
make clean

echo "...make defconfig..."
[ "$1" ] && DEVICE=$1
[ "$DEVICE" ] || DEVICE=r7800

[ -f ".config.$DEVICE" ] || abort "No init config found for $DEVICE"
cp ".config.$DEVICE" .config
echo "...configuring for device: $DEVICE..."
make defconfig

echo "...download new source packages..."
make download || abort "Download source packages failed"

mkdir -p logs
