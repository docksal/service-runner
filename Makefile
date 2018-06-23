-include env_make

VERSION ?= curl-git

REPO = docksal/runner
NAME = docksal-runner-$(VERSION)
IMAGE = $(REPO):$(VERSION)

.PHONY: build test push shell run start stop logs clean release

build:
	docker build -t $(IMAGE) .

test:
	IMAGE=$(IMAGE) NAME=$(NAME) bats tests/test.bats

push:
	docker push $(IMAGE)

shell:
	docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(IMAGE) /bin/sh

run:
	docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(IMAGE)

start: clean
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(IMAGE)

exec:
	docker exec -it $(NAME) /bin/sh

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	docker rm -f $(NAME) >/dev/null 2>&1 || true

release: build push

default: build
