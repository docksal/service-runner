FROM alpine:3.4

RUN apk add --no-cache \
	curl \
	git \
	supervisor \
	&& rm -rf /var/cache/apk/*