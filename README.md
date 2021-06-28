# sshm8

A tool for managing / rotating SSH keys for all your virtual private servers (VPS).

**Note:** tested on Ubuntu 20.04, may work on other versions/distros.

## Overview

Using 1 SSH key for accessing multiple VPS instances is a security concern. If the key's compromised, every instance that authorizes it is vulnerable. A safer alternative is provisioning each VPS instance with a unique SSH key and rotating these regularly. However, this requires the sysadmin to generate and rotate keys. Commands could be typed incorrectly, resulting in loss of access to cloud resources. Furthermore, the sysadmin may forget to rotate keys.

`sshm8` handles key generation and rotation so you don't have to. Similar to a password manager with a main password, `sshm8` initializes with a main keypair. You provision new VPS instances with the main public key so you can authenticate as user *root*. Then, `sshm8` generates a unique SSH key for a non-*root* user of your choice, copies these credentials to the server, and forbids subsequent *root* access to the VPS over SSH. This way, if the main key is compromised, an attacker cannot gain access to existing VPS instances.

`sshm8` comes with a daily cron job that rotates keys for all your VPS instances. Old keys are no longer authorized; only the newly generated ones are. When you SSH into these instances using `sshm8`, it knows what key to use without you having to specify it. Your VPS keys change daily (or however often you want), but you type the same command to access the VPS every time.

## Directory structure

`$ tree ~/.sshm8`

```
.
├── key ("main key")
├── key.pub
├── user@1.2.3.4
│   ├── key
│   └── key.pub
├── user@5.6.7.8
│   ├── key
│   └── key.pub
.
..
...
```

## Install

Clone the repository, then run the following command:

`$ ./install`

And to uninstall:

`$ ./uninstall`

## Usage

### Setup

#### Initial

`$ sshm8 setup`

This generates the main key and writes it to `~/.sshm8/`.

This should be the first step performed after install.

#### VPS

`$ sshm8 setup <user>@<host>`

This command does the following:

1. Generates key for a VPS, identified by username and host (i.e. IP address or hostname)
1. Securely copies `sshd_config` to the VPS (as *root*)
1. Creates `<user>`, copies public key from (1) to their `authorized_keys` file, and reloads [sshd](https://man7.org/linux/man-pages/man8/sshd.8.html)

The `sshd_config` file copied in Step (2) blocks future remote access as *root* and requires public key authentication instead of passwords.

### SSH into VPS

Once VPS setup is complete, you can SSH into the instance:

`$ sshm8 <user>@<host>`

### Print public key

`$ sshm8 pubkey` prints the main public key.

`$ sshm8 pubkey <user>@<host>` prints a server's public key.

### Remove key or `sshm8` entirely

`$ sshm8 remove <user>@<host>` removes the directory containing keys for a VPS.

`$ sshm8 remove` removes the entire `~/.sshm8` directory (read: all keys)

The latter command also deletes the daily cron job.

### cron job

After install, you can find the cron job at `/etc/cron.d/sshm8`.

This cron job runs the [rotate script](./scripts/rotate.sh) daily, generating new keys for each remote server defined in the directory structure.

You can modify the job to run at different times or on different intervals. Check out [crontab](https://man7.org/linux/man-pages/man5/crontab.5.html) for more details.
