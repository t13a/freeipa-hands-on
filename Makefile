MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: init
init: .env

.env:
	./.env.sh  > $@

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
