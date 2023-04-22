# FreeIPA Hands-on

A quick start containerized FreeIPA server (and some extras).

## Features

- All services are containerized
  - FreeIPA server
  - GitLab (with LDAP login)
- Easy to customize (undocumented yet)
  - Generate and edit the configuration file (`.env`)
  - Choose services to use
  - And add your own `docker-compose.*.yml`

## Prerequisites

- Docker (with Compose plugin)
- GNU Make

> **NOTE**:
>
> - If your Docker is runnning with cgroups v2, it must be configured to use user namespace remapping (see [details](https://github.com/freeipa/freeipa-container)).

## Getting started

### Setup

The following commands generate the configuration file (`.env`), create and start all containers. This will take a very long time.

```sh
$ make init
...
$ make up
docker compose up -d --wait
[+] Running 9/9
 ⠿ Network freeipa-hands-on_default               Created                   0.0s
 ⠿ Volume "freeipa-hands-on_gitlab_conf"          Created                   0.0s
 ⠿ Volume "freeipa-hands-on_gitlab_data"          Created                   0.0s
 ⠿ Volume "freeipa-hands-on_gitlab_logs"          Created                   0.0s
 ⠿ Volume "freeipa-hands-on_ipa_data"             Created                   0.0s
 ⠿ Volume "freeipa-hands-on_ipa_journal"          Created                   0.0s
 ⠿ Container freeipa-hands-on-ipa-1               Healthy                 558.0s
 ⠿ Container freeipa-hands-on-gitlab-init-ldap-1  Exited                  556.8s
 ⠿ Container freeipa-hands-on-gitlab-1            Healthy                 783.8s
```

To access Web UIs, you will need to add some entries to `/etc/hosts` on your host.

The following command shows the IP address and domain name of the containers (you can add this to `/etc/hosts` directly).

```sh
$ make hosts
172.17.2.3 gitlab.example.internal # freeipa-hands-on-gitlab-1
172.17.2.2 ipa.example.internal # freeipa-hands-on-ipa-1
```

Then, you will be able to access the following services.

- GitLab: `http://gitlab.example.internal/`
- FreeIPA: `https://ipa.example.internal/`

### Teardown

The following commands remove all containers and volumes, and the configuration file (`.env`).

```sh
$ make down
$ make clean
```

## Troubleshooting

### Can not resolve GitLab's IP address when using FreeIPA as DNS server

Add `A` record individually.

```sh
$ docker compose exec ipa ipa dnsrecord-add example.internal gitlab --a-ip-address=172.17.2.3
  Record name: gitlab
  A record: 172.17.2.3
```

### Password expiration date is too short

Set a long expiration date when adding user.

```sh
$ docker compose exec ipa ipa user-add \
    johnsmith \
    --first='John' \
    --last='Smith' \
    --password-expiration=9999-12-24T23:59Z \
    --password <<< '********'
```

Or disable password expiration for all users.

```sh
$ docker compose exec ipa ipa pwpolicy-mod global_policy --minlife 0 --maxlife 0
  Group: global_policy
  Max lifetime (days): 0
  Min lifetime (hours): 0
  History size: 0
  Character classes: 0
  Min length: 8
  Max failures: 6
  Failure reset interval: 60
  Lockout duration: 600
  Grace login limit: -1
```

## Reference

- [FreeIPA server in containers](https://github.com/freeipa/freeipa-container)
- [Web application authentication developer setup ](https://github.com/adelton/webauthinfra)
- [Configure GitLab FreeIPA LDAP Authentication | ComputingForGeeks](https://computingforgeeks.com/how-to-configure-gitlab-freeipa-authentication/)
- [How To Configure FreeIPA Client on Ubuntu / CentOS 7 | ComputingForGeeks](https://computingforgeeks.com/how-to-configure-freeipa-client-on-ubuntu-centos/)
