#!/bin/bash

if ! [ -d ~/.sshm8 ]; then
    >&2 echo "No directory: ~/.sshm8"
    exit 1
fi

cd ~/.sshm8

for dir in */; do
    cd ~/.sshm8
    cd "$dir"

    target="$(echo "$dir" | sed 's/\///')"

    ssh-keygen \
        -N '' \
        -f newkey \
        -t ed25519 \
        > "$output"

    echo "Generated new SSH key"

    ssh-copy-id \
        -f \
        -i newkey \
        -o BatchMode=yes \
        -o ConnectTimeout=10 \
        -o IdentityFile=key \
        "$target" \
        > "$output"

    echo "Copied new public key to server"

    mv newkey key
    mv newkey.pub key.pub

    ssh \
        -i key \
        -o BatchMode=yes \
        -o ConnectTimeout=10 \
        "$target" \
        'key="$(tail -1 ~/.ssh/authorized_keys)"; echo "$key" > ~/.ssh/authorized_keys'

    sleep 1
done
