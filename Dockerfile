FROM alpine:3.4

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories

RUN apk add --no-cache \
	shadow \
	curl \
	git \
	supervisor \
	sudo \
	su-exec \
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
	useradd -m -s /bin/bash -u 1000 -g 1000 -p docker docker; \
	echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers;

COPY entrypoint.sh /opt/entrypoint.sh

WORKDIR /var/www

ENTRYPOINT ["/opt/entrypoint.sh"]