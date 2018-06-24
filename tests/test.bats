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

	run docker run -it --name "$NAME" \
		-e "HOST_UID=${UID}" \
		-e "HOST_GID=${GID}" \
		-v $(pwd)/tests:/var/www/ \
		"$IMAGE" \
		whoami

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "docker" ]]
	unset output

	# Clean Up
	make clean
}

@test "Confirm Current Location Is /var/www" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it --name "$NAME" \
		-e "HOST_UID=${UID}" \
		-e "HOST_GID=${GID}" \
		-v $(pwd)/tests:/var/www/ \
		"$IMAGE" \
		pwd

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "/var/www" ]]
	unset output

	# Clean Up
	make clean
}

@test "Confirm GIT Installed" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it --name "$NAME" \
		-e "HOST_UID=${UID}" \
		-e "HOST_GID=${GID}" \
		-v $(pwd)/tests:/var/www/ \
		"$IMAGE" \
		git --version

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "git version" ]]
	unset output

	# Clean Up
	make clean
}

@test "Confirm GIT Downloads" {
	[[ $SKIP == 1 ]] && skip

	docker run -it --name "$NAME" \
		-e "HOST_UID=${UID}" \
		-e "HOST_GID=${GID}" \
		-v $(pwd)/tests:/var/www/ \
		"$IMAGE" \
		git clone https://github.com/docksal/drupal8.git

	[[ -d $(pwd)/tests/drupal8 ]] &&
	[[ -f $(pwd)/tests/drupal8/docroot/index.php ]]

	rm -rf $(pwd)/tests/drupal8

	# Clean Up
	make clean
}

@test "Confirm CURL Installed" {
	[[ $SKIP == 1 ]] && skip

	run docker run -it "$NAME" \
		-e "HOST_UID=${UID}" \
		-e "HOST_GID=${GID}" \
		-v $(pwd)/tests:/var/www/ \
		"$IMAGE" \
		curl --version

	[[ $status -eq 0 ]] &&
	[[ "${output}" =~ "curl version" ]]
	unset output

	# Clean Up
	make clean
}

@test "Confirm Curl Downloads" {
	[[ $SKIP == 1 ]] && skip

	docker run -it \
		--name "$NAME" \
		-e "HOST_UID=${UID}" \
		-e "HOST_GID=${GID}" \
		-v $(pwd)/tests:/var/www/ \
		"$IMAGE" \
		curl -O services.yml "https://raw.githubusercontent.com/docksal/docksal/develop/stacks/services.yml"

	run grep "This is a library of preconfigured services for Docksal" $(pwd)/tests/services.yml
	[[ -f $(pwd)/tests/services.yml ]] &&
	[[ $status -eq 0 ]]

	rm -rf ${pwd}/tests/services.yml

	# Clean Up
	make clean
}