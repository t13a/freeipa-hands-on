MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: init
init: .env

.env: COMPOSE_FILE ?= \
	docker-compose.base.yml docker-compose.docker-volume.yml
ifneq ($(wildcard /var/run/docker.sock),) # Pass the socket to Docker-included containers.
.env: COMPOSE_FILE += docker-compose.docker-socket.yml
endif
ifeq ($(shell stat -fc %T /sys/fs/cgroup),tmpfs) # With cgroups v1, add bind mount to SystemD-based containers.
.env: COMPOSE_FILE += docker-compose.cgroups-v1.yml
endif
.env: COMPOSE_PROFILES ?= all
.env: TZ ?= $(shell timedatectl show -p Timezone --value)
.env:
	( \
		cat base.env \
		&& echo COMPOSE_FILE=$(COMPOSE_FILE) | tr ' ' ':' \
		&& echo COMPOSE_PROFILES=$(COMPOSE_PROFILES) \
		&& echo TZ=$(TZ) \
	) > $@

.PHONY: clean
clean:
	rm -f .env

.PHONY: up
up:
	docker compose up -d --wait

.PHONY: down
down:
	docker compose down -v

.PHONY: hosts
hosts:
	@for name in $$(docker compose ps | tail -n +2 | cut -d' ' -f1); \
	do \
		hostname="$$(docker inspect --format="{{.Config.Hostname}}" $$name)"; \
		ip="$$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $$name)"; \
		printf '%s %s # %s\n' $$ip $$hostname $$name; \
	done
