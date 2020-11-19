#!/bin/bash

#check parameters
if test "$#" -ne 1; then
    echo "Illegal number of parameters. Usage: $0 watched_directory"
    exit 1
fi


if test ! -d "$1"; then
    echo "$1 directory does not exists."
    exit 1
fi

# check dependencies
if ! type inotifywait &>/dev/null ; then
	echo "You are missing the inotifywait dependency. Install the package inotify-tools (apt-get install inotify-tools)"
	exit 1
fi

# can be modified
serverIp="127.0.0.1"

#######
# Set monitoring 
#######

FIFO="/tmp/inotify2.fifo"

on_exit() {
	kill $INOTIFY_PID
	rm $FIFO
	exit
}

if [ ! -e "$FIFO" ];then
	mkfifo "$FIFO"
fi


# monitoring
inotifywait -q -r -e delete_self,modify,move,delete,create -m "$1" > "$FIFO" &

INOTIFY_PID=$!

trap "on_exit" 1 2 3 15


user=$(whoami)

serverHostName=$(nslookup $serverIp -timeout=5 | awk 'NR==1 { print $4 } ')
updateDir="/tmp/fileUpdates"


#######
# Create ssh key and connect to server
#######

keyPath="~/.ssh/id_rsa"

# if ssh key is not defined
if [[ ! $(ls -al ~/.ssh/id_*.pub) ]]; then
    ssh-keygen -t rsa -b 4096
fi

# works well but dupplicates key 
#ssh-copy-id "$user"@"$serverHostName"


# save key if it does not exist, but does not add it if already saved
cat ~/.ssh/id_*.pub | 
ssh -T "$user"@"$serverHostName" 'mkdir -pm 0700 ~/.ssh &&
    while read -r ktype key comment; do
        if ! (grep -Fw "$ktype $key" ~/.ssh/authorized_keys | grep -qsvF "^#"); then
            echo "$ktype $key $comment" >> ~/.ssh/authorized_keys
        fi
    done'


#######
# On event
#######

while read -r directory events filename; do
	if [[ "$events" = DELETE_SELF ]]; then
		on_exit
	else
    	rsync -a --delete -e ssh "$1"/ "$user"@"$serverHostName":"$updateDir"
	fi
done < "$FIFO" &