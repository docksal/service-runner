#!/usr/bin/env bats

# Debugging
teardown () {
	echo
	# TODO: figure out how to deal with this (output from previous run commands showing up along with the error message)
	echo "Note: ignore the lines between \"...failed\" above and here"
	echo
	echo "Status: $status"
	echo "Output:"
	echo "================================================================"
	echo "$output"
	echo "================================================================"
}

# Global skip
# Uncomment below, then comment skip in the test you want to debug. When done, reverse.
#SKIP=1

@test "Confirm Current User Is Docker" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		whoami

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "docker" ]]
	unset output
}

@test "Confirm Current User Matches Host" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		'id -u'

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "${UID}" ]]
	unset output

	run docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		'id -g'

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "${GID}" ]]
	unset output
}

@test "Confirm Current Location Is /home/docker" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		"$IMAGE" \
		pwd

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "/home/docker" ]]
	unset output
}

@test "Confirm GIT Installed" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		git --version

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "git version" ]]
	unset output
}

@test "Confirm GIT Downloads" {
	[[ $SKIP == 1 ]] && skip

	docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		git clone https://github.com/docksal/drupal8.git

	[[ -d $(pwd)/tests/drupal8 ]] &&
	[[ -f $(pwd)/tests/drupal8/docroot/index.php ]]

	rm -rf $(pwd)/tests/drupal8
}

@test "Confirm CURL Installed" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		curl --version

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "curl" ]] &&
	[[ "${output}" =~ "Release-Date:" ]]
	unset output
}

@test "Confirm Curl Downloads" {
	[[ $SKIP == 1 ]] && skip

	docker run -it \
		--rm \
		--mount type=bind,src=$(pwd)/tests,dst=/var/www \
		--mount type=volume,src=docksal_ssh_agent,dst=/.sshagent,readonly \
		--name "$NAME" \
		-e HOST_UID \
		-e HOST_GID \
		"$IMAGE" \
		curl -O services.yml https://raw.githubusercontent.com/docksal/docksal/develop/stacks/services.yml

	run grep "This is a library of preconfigured services for Docksal" $(pwd)/tests/services.yml
	[[ -f $(pwd)/tests/services.yml ]] &&
	[[ $status -eq 0 ]]

	rm -rf ${pwd}/tests/services.yml
}