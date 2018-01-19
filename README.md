# What is docker-jail?

This repository contains a
[Dockerfile](https://docs.docker.com/engine/reference/builder/) that build a
minimal container image that can be used to create SSH jails to isolate users
on a shared system. It is focused on providing a minimal set of tools that
provide common functionality (e.g., rsync, sftp) on many shared hosts.

## Setting Up SSH Jails

To run this image, you'll need to make sure that [Docker
Engine](https://www.docker.com/products/docker-engine) is installed. Jailed
users will also need to be members of the `docker` group. Next you need to
configure Open SSH to force commands to be run in containers. 

### Configuring Open SSH

On Debian/Ubuntu, the OpenSSH configuration file is located at `/etc/ssh/sshd_config`. Below is
an example snippet that an be added to this file to jail users that belong to
the `jailed` group.

```
Match Group jailed
      ForceCommand /usr/local/containerize.sh
      AllowTcpForwarding no
      PermitTunnel no
      X11Forwarding no
```

This snippet forces any user belonging to the `jailed` group to run the
`containerize.sh` script when connecting via SSH. Additionally, it disallows
several SSH options to further lock down users.

### Containerization Script

The previous OpenSSH snippet references a script that is used to containerize
commands on each SSH connection. Below is an example of what such a script
might look like:

```
#!/bin/sh

containerize()
{
    docker run --rm $1 \
               -v /etc/group:/etc/group:ro \
               -v /etc/passwd:/etc/passwd:ro \
               -v $HOME:$HOME \
               --workdir $HOME \
               --hostname $(hostname) \
               -u $(id -u $USER):$(id -g $USER) \
               chazlever/docker-jail:latest $SSH_ORIGINAL_COMMAND
}

# Check if TTY allocated
if tty -s; then
    containerize -it
else
    containerize -i
fi
```

This script spawns a new container for any command sent over SSH by using the
`SSH_ORIGINAL_COMMAND` environment variable. It also checks whether a TTY was
requested and configures the `docker run` command accordingly.
