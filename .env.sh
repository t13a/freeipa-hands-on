#!/bin/sh

set -eu

compose_file="${COMPOSE_FILE:-docker-compose.base.yml:docker-compose.docker-volume.yml}"

# Pass the socket to Docker-included containers.
if [ -S /var/run/docker.sock ]
then
    compose_file="${compose_file}:docker-compose.docker-socket.yml"
fi

# With cgroups v1, add bind mount to SystemD-based containers.
if [ "$(stat -fc %T /sys/fs/cgroup)" = tmpfs ]
then
    compose_file="${compose_file}:docker-compose.cgroups-v1.yml"
fi

compose_profiles=${COMPOSE_PROFILES:-all}

docker_host=${DOCKER_HOST:-unix:///var/run/docker.sock}

domain="${DOMAIN:-example.internal}"
realm="$(echo "${domain}" | tr '[:lower:]' '[:upper:]')"
dn="dc=$(echo "${domain}" | sed 's/\./,dc=/g')"

password="${PASSWORD:-Secret123}"

# Due to Docker Compose limitations, backquote characters are not escaped.
password_quoted="\"$(echo "${password}" | sed 's/\(["$]\)/\\\1/g')\""

tz="${TZ:-$(timedatectl show -p Timezone --value)}"

cat << EOF
COMPOSE_FILE=${compose_file}
COMPOSE_PROFILES=${compose_profiles}

DOCKER_HOST=${docker_host}

DOMAIN=${domain}
REALM=${realm}
TZ=${tz}

GITLAB_HOSTNAME=gitlab.${domain}
GITLAB_LDAP_BASE_DN=cn=accounts,${dn}
GITLAB_LDAP_BIND_DN=uid=gitlab,cn=users,cn=accounts,${dn}
GITLAB_LDAP_BIND_PASSWORD=${password_quoted}
GITLAB_LDAP_BIND_USERNAME=gitlab

IPA_ADMIN_PASSWORD=${password_quoted}
IPA_ADMIN_USERNAME=admin
IPA_HOSTNAME=ipa.${domain}
IPA_SERVER_INSTALL_OPTS="--unattended --domain=${domain} --realm=${realm} --no-ntp --setup-dns --forwarder=127.0.0.11"
EOF
