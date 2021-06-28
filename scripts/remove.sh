#!/bin/bash

if [ -z "$1" ]; then
    read -rp "Are you sure you want to remove sshm8? [y/N]: " resp

    if [ "${resp,,}" == y ] || [ "${resp,,}" == yes ]; then
        rm -rf ~/.sshm8
    fi

    exit
fi

if ! [ -d ~/.sshm8/"$1" ]; then
    >&2 echo "No directory: ~/.sshm8/$1"
    exit 1
fi

rm -rf ~/.sshm8/"$1"
echo "Removed keys"
