#!/bin/bash

CPU_THREADS=$(grep -c "processor" /proc/cpuinfo)
# amount of cpu threads to use in kernel make process
THREADS=$((CPU_THREADS + 1))
VERBOSITY=
DEBUG=false

abort() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

do_make() {
	make -j$THREADS $VERBOSITY "$1" 2>&1 | tee logs/build.log | grep -iE --color "make(\[[0-9]+\]|.*error)"
	return ${PIPESTATUS[0]}
}

continue_build() {
	echo "...continuing build..."
	mkdir -p logs

	$DEBUG && THREADS=1
	VERBOSITY="V=s"
	do_make "$package" || abort "Firmware build failed"

	echo "Build complete"

	exit 0
}

start_build() {
	echo "...starting build..."
	mkdir -p logs

	do_make "$package" || abort "Firmware build failed"

	echo "Build complete!"

	exit 0
}

umask 0022

package=world
do_continue=
while [ $# != 0 ]; do
	if [ "$1" = "--continue" ] || [ "$1" == "-c" ]; then
		do_continue=y
	elif [ ! "$package" ] || [ "$package" == "world" ]; then
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
	[ "$do_continue" ] || read -rp "Continue previous build (Y(es)/N(o)/D(ebug))? " do_continue
	case $do_continue in
	N*|n*)
		echo "...cleaning build..."
		make clean
		;;
	D*|d*)
		DEBUG=true
		continue_build
		;;
	*)
		continue_build
		;;
	esac
	break
done

[ -f .config ] || { ./prepare.sh || abort "Failed build preparations"; }

start_build
