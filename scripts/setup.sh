#!/bin/bash

cd "$(dirname "$0")"

if [ -z "$1" ]; then
    mkdir -p ~/.sshm8

    ssh-keygen \
        -N '' \
        -f ~/.sshm8/key \
        -t ed25519

    echo "Generated main key"

    exit
fi

mkdir -p ~/.sshm8/"$1"

ssh-keygen \
    -N '' \
    -f ~/.sshm8/"$1"/key \
    -t ed25519

echo "Generated key for $1"

root="${1/[^@\s]*@/root@}"
user="${1%@*}"

scp \
    -i ~/.sshm8/key \
    -o ConnectTimeout=10 \
    ../sshd_config \
    "$root":/etc/ssh/sshd_config \
    > "$output"

echo "Copied sshd_config to remote server"

pubkey="$(cat ~/.sshm8/"$1"/key.pub)"

ssh \
    -i ~/.sshm8/key \
    -o ConnectTimeout=10 \
    "$root" \
    "useradd -m -G sudo -s /bin/bash \"$user\"; \
    echo \"Please enter password for user: \"$user\"\"; \
    passwd \"$user\"; \
    mkdir -p /home/\"$user\"/.ssh; \
    echo \"$pubkey\" > /home/\"$user\"/.ssh/authorized_keys; \
    chown -R \"$user\":\"$user\" /home/\"$user\"/.ssh; \
    systemctl reload sshd;"

echo "Copied SSH key and reloaded sshd"
echo "You can now access server: \`sshm8 $1\`"
