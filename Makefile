.DELETE_ON_ERROR:

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

DOCKER_COMPOSE_FILES := docker-compose.yml
ifeq ($(wildcard /sys/fs/cgroup/cgroup.controllers),) # cgroups v1
DOCKER_COMPOSE_FILES += docker-compose.cgroups-v1.yml
endif
ifeq ($(EXPOSE),1) # specify `EXPOSE=1`
DOCKER_COMPOSE_FILES += docker-compose.expose.yml
endif

ifneq ($(wildcard /sys/fs/cgroup/cgroup.controllers),) # cgroups v2
ifeq ($(shell docker info | grep userns),)
$(warning User namespace remapping is not used (see: https://github.com/freeipa/freeipa-container).)
endif
endif

.PHONY: up
up: up/no-wait wait info

.PHONY: up/no-wait
up/no-wait: .env
	docker compose $(addprefix -f ,$(DOCKER_COMPOSE_FILES)) up -d

.PHONY: down
down: .env
	docker compose down -v

.PHONY: start
start: start/no-wait wait info

.PHONY: start/no-wait
start/no-wait: .env
	docker compose start

.PHONY: stop
stop: .env
	docker compose stop

.PHONY: wait
wait:
	./exec-until-healthy.sh docker compose logs -f --no-log-prefix ipa || true

.PHONY: exec
exec: CMD := bash
exec: .env
	@docker compose exec ipa $(CMD)

.PHONY: info
info: IPA_SERVER_HOSTNAME = $(shell set -a; source ./.env; set +a; printenv IPA_SERVER_HOSTNAME)
info: PASSWORD = $(shell set -a; source ./.env; set +a; printenv PASSWORD)
info: .env
	@$(info )
	@$(info Web UI: https://$(IPA_SERVER_HOSTNAME)/ipa/ui/)
	@$(info Username: admin)
	@$(info Password: $(PASSWORD))
	@$(info )

.PHONY: clean
clean:
	rm -f .env

.env: DOMAIN = example.test
.env: IPA_HOST_IP = 0.0.0.0
.env: IPA_HOST_PORT_DNS = 53
.env: IPA_HOST_PORT_HTTP = 80
.env: IPA_HOST_PORT_HTTPS = 443
.env: IPA_HOST_PORT_KERBEROS = 88
.env: IPA_HOST_PORT_KPASSWD = 464
.env: IPA_HOST_PORT_LDAP = 389
.env: IPA_HOST_PORT_LDAPS = 636
.env: IPA_HOST_PORT_NTP = 123
.env: IPA_SERVER_HOSTNAME = ipa.$(DOMAIN)
.env: IPA_SERVER_IP = 
.env: IPA_SERVER_INSTALL_OPTS = \
	--unattended \
	--domain=$(DOMAIN) \
	--realm=$(shell echo $(DOMAIN) | tr [:lower:] [:upper:]) \
	--no-ui-redirect \
	--no-ntp
.env: PASSWORD = Secret123
.env:
	rm -f $@
	echo 'IPA_HOST_IP=$(IPA_HOST_IP)' >> $@
	echo 'IPA_HOST_PORT_DNS=$(IPA_HOST_PORT_DNS)' >> $@
	echo 'IPA_HOST_PORT_HTTP=$(IPA_HOST_PORT_HTTP)' >> $@
	echo 'IPA_HOST_PORT_HTTPS=$(IPA_HOST_PORT_HTTPS)' >> $@
	echo 'IPA_HOST_PORT_KERBEROS=$(IPA_HOST_PORT_KERBEROS)' >> $@
	echo 'IPA_HOST_PORT_KPASSWD=$(IPA_HOST_PORT_KPASSWD)' >> $@
	echo 'IPA_HOST_PORT_LDAP=$(IPA_HOST_PORT_LDAP)' >> $@
	echo 'IPA_HOST_PORT_LDAPS=$(IPA_HOST_PORT_LDAPS)' >> $@
	echo 'IPA_HOST_PORT_NTP=$(IPA_HOST_PORT_NTP)' >> $@
	echo 'IPA_SERVER_HOSTNAME=$(IPA_SERVER_HOSTNAME)' >> $@
	echo 'IPA_SERVER_INSTALL_OPTS="$(IPA_SERVER_INSTALL_OPTS)"' >> $@
	echo 'IPA_SERVER_IP=$(IPA_SERVER_IP)' >> $@
	echo 'PASSWORD="$(PASSWORD)"' >> $@
