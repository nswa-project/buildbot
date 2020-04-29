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
			shift=
			;;
		--make-jobs)
			MAKE_JOBS="$1"
			shift
			;;
		--make-target)
			MAKE_TARGET="$1"
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
[ -z "$MAKE_JOBS" ] && MAKE_JOBS=`nproc`

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

	rm -f "$TARGET_DIR/.config.old"
	cp "$PREFIX/configs/$i" "$TARGET_DIR/.config"

	(cd "$TARGET_DIR"; make defconfig)
	evck "$?"
	(cd "$TARGET_DIR"; make "-j${MAKE_JOBS}" ${MAKE_TARGET})
	evck "$?"
done
