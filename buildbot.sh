#!/bin/bash

evck() {
	[ "$1" = "0" ] && return

	info "ERROR"
	exit 1
}

info() {
	echo "[buildbot] $*"
}

PREFIX=`dirname "$0"`

while true ; do
	opt="$1"
	if [ "$opt" = "" ] || [ "$opt" = "--" ]; then
		shift
		break
	fi
	
	if [ "${opt:0:1}" = "-" ]; then
		shift

		case "${opt}" in
		--include-targets)
			INCLUDE_TARGETS="$1"
			shift
			;;
		--exclude-targets)
			EXCLUDE_TARGETS="$1"
			shift
			;;
		--ls-targets)
			ls "$PREFIX/configs"
			exit
			;;
		--openwrt-dir)
			TARGET_DIR="$1"
			shift
			;;
		--test-build)
			TEST_BUILD=1
			;;
		--help)
			usage
			exit
			;;
		*)
			echo "unknown option $opt"
			exit
			;;
		esac
	else
		break
	fi
done

TARGET_DIR="${TARGET_DIR:-.}"

for i in `ls $PREFIX/configs`; do
	if [[ -n "$INCLUDE_TARGETS" && ! " $INCLUDE_TARGETS " =~ " $i " ]]; then
		info "ignore $i"
		continue
	fi

	if [[ -n "$EXCLUDE_TARGETS" && " $EXCLUDE_TARGETS " =~ " $i " ]]; then
		info "ignore $i"
		continue
	fi

	info "==> $i"

	[ "$TEST_BUILD" = '1' ] && continue

	rm "$TARGET_DIR/.config.old"
	cp "$PREFIX/configs/$i" "$TARGET_DIR/.config"

	(cd "$TARGET_DIR"; make defconfig)
	evck "$?"
	(cd "$TARGET_DIR"; make -j`nproc`)
	evck "$?"
done
