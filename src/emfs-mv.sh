#!/usr/bin/env bash

if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 source dest"
	exit 1
fi

old=$1
new=$2

ruby emfs-get.rb "$old"

if [[ "$?" -ne 0 ]]; then
	exit $?
fi

ruby emfs-rm.rb "$old"

if [[ "$?" -ne 0 ]]; then
	exit $?
fi

mv "$old" "$new"
ruby emfs-put.rb "$new"
rm "$new"

exit 0
