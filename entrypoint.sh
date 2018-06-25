#!/bin/sh
set -e

export HOME_DIR='/home/docker'

echo_debug ()
{
	[[ "$DEBUG" != 0 ]] && echo "$(date +"%F %H:%M:%S") | $@" || true
}

uid_gid_reset ()
{
	if [[ "$HOST_UID" != "$(id -u docker)" ]] || [[ "$HOST_GID" != "$(id -g docker)" ]]; then
		echo_debug "Updating docker user uid/gid to $HOST_UID/$HOST_GID to match the host user uid/gid..."
		usermod -u "$HOST_UID" -o docker
		groupmod -g "$HOST_GID" -o "$(id -gn docker)"
	fi
}

# Docker user uid/gid mapping to the host user uid/gid
[[ "$HOST_UID" != "" ]] && [[ "$HOST_GID" != "" ]] && uid_gid_reset

# Make sure permissions are correct (after uid/gid change and COPY operations in Dockerfile)
# To not bloat the image size, permissions on the home folder are reset at runtime.
echo_debug "Resetting permissions on $HOME_DIR and /var/www..."
chown "${HOST_UID-:1000}:${HOST_GID:-1000}" -R "$HOME_DIR"
# Docker resets the project root folder permissions to 0:0 when runner is recreated (e.g. an env variable updated).
# We apply a fix/workaround for this at startup (non-recursive).
chown "${HOST_UID-:1000}:${HOST_GID:-1000}" -R /var/www

# Any other command (assuming container already running)
exec gosu docker sh -c "$*"