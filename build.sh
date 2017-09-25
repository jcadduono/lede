#!/bin/bash

abort() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

continue_build() {
	echo "...continuing build (debug)..."
	mkdir -p logs

	make -j1 V=s "$package" 2>&1 | tee logs/build.log | grep -iE --color "make(\[[0-9]+\]|.*error)"
	[ ${PIPESTATUS[0]} -eq 0 ] || abort "Firmware build failed"

	echo "Build complete"

	exit 0
}

start_build() {
	echo "...starting build..."
	mkdir -p logs

	make -j9 "$package" 2>&1 | tee logs/build.log | grep -iE --color "make(\[[0-9]+\]|.*error)"
	[ ${PIPESTATUS[0]} -eq 0 ] || abort "Firmware build failed"

	echo "Build complete!"

	exit 0
}

umask 0022

package=world
do_continue=
while [ $# != 0 ]; do
	if [ "$1" = "--continue" ] || [ "$1" == "-c" ]; then
		do_continue=y
	elif [ ! "$package" ]; then
		package=$1
	else
		echo "Too many arguments!"
		echo "Usage: ./build.sh [--continue] [package]"
		abort
	fi
	shift
done

for bdir in build_dir/target-*; do
	[ -d "$bdir" ] || continue
	echo "Previous build target found at '$bdir'!"
	[ "$do_continue" ] || read -rp "Continue previous build (Y/n)? " do_continue
	case $do_continue in
	N*|n*)
		echo "...cleaning build..."
		make clean
		;;
	*)
		continue_build
		;;
	esac
	break
done

[ -f .config ] || { ./prepare.sh || abort "Failed build preparations"; }

start_build
