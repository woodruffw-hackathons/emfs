#!/usr/bin/env bash

if [[ -z "$1" || ! -d "$1" || $(ls -A $1) ]]; then
	echo "Usage: $0 <empty directory>"
	exit 1
fi

dir=$1

printf "Beginning sync..."

for file in $(ruby emfs-ls.rb); do
	ruby emfs-get.rb $file ${dir}/${file} &
done

wait

printf "all files copied. Idling...\n"

inotifywait -qm $dir --format '%e %f' -e create -e moved_to -e modify -e moved_from -e delete |
while read event file; do
	echo "Event: $event on $file"

	if [[ "$event" = "CREATE" ]] || [[ "$event" = "MOVED_TO" ]]; then
		ruby emfs-put.rb "${dir}/${file}"
	elif [[ "$event" = "MODIFY" ]]; then
		ruby emfs-rm.rb "${dir}/${file}"
		ruby emfs-put.rb "${dir}/${file}"
	elif [[ "$event" = "MOVED_FROM" ]] || [[ "$event" = "DELETE" ]]; then
		ruby emfs-rm.rb "${dir}/${file}" &
	fi
done
