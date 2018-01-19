# Run shell to be used in jailed SSH environment
#
# docker run --rm -it \
#	-v /etc/passwd:/etc/passwd:ro \
#	-v /etc/group:/etc/group:ro \
#	-v $HOME:$HOME \
#  --workdir $HOME \
#  --hostname $(hostname) \
#  -u $(id -u $USER):$(id -g $USER) \
#	chazlever/docker-jail:latest
#

FROM debian:jessie
LABEL maintainer "Chaz Lever <chazlever@users.noreply.github.com>"

RUN apt-get update && apt-get install -y \
    ssh \
    rsync \
   && rm -rf /var/list/apt/lists/*

