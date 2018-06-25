FROM alpine:3.4

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories

RUN apk add --no-cache \
	shadow \
	curl \
	git \
	supervisor \
	sudo \
	&& rm -rf /var/cache/apk/*

ENV \
	DEBUG=0 \
	# ssh-agent proxy socket (requires docksal/ssh-agent)
	SSH_AUTH_SOCK=/.ssh-agent/proxy-socket \
	# Default values for HOST_UID and HOST_GUI to match the default Ubuntu user. These are used in entrypoint.sh
	HOST_UID=1000 \
	HOST_GID=1000

RUN set -xe; \
	# Create a regular user/group "docker" (uid = 1000, gid = 1000 ) with access to sudo
	groupadd docker -g 1000; \
	useradd -m -s /bin/sh -u 1000 -g 1000 -p docker docker; \
	echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers;

# Install gosu and give access to the docker user primary group to use it.
# gosu is used instead of sudo to start the main container process (pid 1) in a docker friendly way.
# https://github.com/tianon/gosu
RUN set -xe; \
	curl -sSL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" -o /usr/local/bin/gosu; \
	chown root:"$(id -gn docker)" /usr/local/bin/gosu; \
	chmod +sx /usr/local/bin/gosu

COPY entrypoint.sh /opt/entrypoint.sh

WORKDIR /var/www

ENTRYPOINT ["/opt/entrypoint.sh"]