#!/bin/bash

# check dependencies
if ! type inotifywait &>/dev/null ; then
	echo "You are missing the inotifywait dependency. Install the package inotify-tools (apt-get install inotify-tools)"
	exit 1
fi

if test "$#" -ne 1; then
    echo "Illegal number of parameters. Usage: $0 destination_directory"
    exit 1
fi


if test ! -d "$1"; then
    echo "$1 directory does not exists."
    exit 1
fi


FIFO="/tmp/inotify2.fifo"

on_exit() {
	kill $INOTIFY_PID
	rm $FIFO
	exit
}

if [ ! -e "$FIFO" ];then
	mkfifo "$FIFO"
fi

updateDir="/tmp/fileUpdates"

# monitoring
inotifywait -q -r -e delete_self,modify,move,delete,create -m "$updateDir" > "$FIFO" &

INOTIFY_PID=$!

trap "on_exit" 1 2 3 15

while read -r directory events filename; do
	if [[ "$events" = DELETE_SELF ]]; then
		on_exit
	else
    	rsync -av --delete "$updateDir"/ "$1"
	fi
done < "$FIFO" &
