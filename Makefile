MAKEFLAGS += --no-builtin-rules --no-builtin-variables

DOCKER_COMPOSE_FILES := docker-compose.yml
ifeq ($(wildcard /sys/fs/cgroup/cgroup.controllers),) # cgroups v1
DOCKER_COMPOSE_FILES += docker-compose.cgroups-v1.yml
endif

ifneq ($(wildcard /sys/fs/cgroup/cgroup.controllers),) # cgroups v2
ifeq ($(shell docker info | grep userns),)
$(warning User namespace remapping is not used (see: https://github.com/freeipa/freeipa-container).)
endif
endif

.PHONY: up
up: up/no-wait wait info

.PHONY: up/no-wait
up/no-wait:
	docker compose $(addprefix -f ,$(DOCKER_COMPOSE_FILES)) up -d

.PHONY: down
down:
	docker compose down -v

.PHONY: start
start: start/no-wait wait

.PHONY: start/no-wait
start/no-wait:
	docker compose start

.PHONY: stop
stop:
	docker compose stop

.PHONY: wait
wait:
	hack/wait-for-healthy.sh ipa docker compose logs -f --no-log-prefix ipa || true

.PHONY: info
info: IPA_SERVER_HOSTNAME = $(shell hack/dotenv.sh .env -- printenv IPA_SERVER_HOSTNAME)
ifneq ($(shell hack/dotenv.sh .env -- printenv IPA_SERVER_IP),)
info: IPA_SERVER_IP = $(shell hack/dotenv.sh .env -- printenv IPA_SERVER_IP)
else
info: DOCKER_NETWORK_NAME = $(shell hack/dotenv.sh .env -- printenv DOCKER_NETWORK_NAME)
info: COMPOSE_PROJECT_NAME = $(shell hack/dotenv.sh .env -- printenv COMPOSE_PROJECT_NAME)
info: IPA_SERVER_IP = $(shell hack/print-container-ip-address.sh $(DOCKER_NETWORK_NAME) $(COMPOSE_PROJECT_NAME)-ipa-1)
endif
info:
	@echo
	@echo 'Append following line to /etc/hosts, or add a A record to your DNS.'
	@echo '> $(IPA_SERVER_IP) $(IPA_SERVER_HOSTNAME)'
	@echo

.PHONY: exec
exec: CMD := bash
exec:
	@docker compose exec ipa $(CMD)
