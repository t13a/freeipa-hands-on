MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: up
up: up/no-wait wait info

.PHONY: up/no-wait
up/no-wait:
	docker compose up -d

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
	../hack/wait-for-healthy.sh gitlab docker compose logs -f --no-log-prefix gitlab || true

.PHONY: info
info: GITLAB_HOSTNAME = $(shell ../hack/dotenv.sh .env -- printenv GITLAB_HOSTNAME)
info: DOCKER_NETWORK_NAME = $(shell ../hack/dotenv.sh .env -- printenv DOCKER_NETWORK_NAME)
info: COMPOSE_PROJECT_NAME = $(shell ../hack/dotenv.sh .env -- printenv COMPOSE_PROJECT_NAME)
info: GITLAB_IP = $(shell ../hack/print-container-ip-address.sh $(DOCKER_NETWORK_NAME) $(COMPOSE_PROJECT_NAME)-gitlab-1)
info:
	@echo
	@echo 'Append following line to /etc/hosts, or add a A record to your DNS.'
	@echo '> $(GITLAB_IP) $(GITLAB_HOSTNAME)'
	@echo

.PHONY: exec
exec: CMD := bash
exec:
	@docker compose exec gitlab $(CMD)
