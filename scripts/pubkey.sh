#!/bin/bash

if [ -z "$1" ]; then
    cat ~/.sshm8/key.pub
    exit
fi

if [ -d ~/.sshm8/"$1" ]; then
    cat ~/.sshm8/"$1"/key.pub
    exit
fi

>&2 echo "Couldn't find public key for $1"
exit 1
