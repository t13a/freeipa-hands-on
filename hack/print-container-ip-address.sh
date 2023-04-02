#!/bin/sh

set -eu

docker inspect --format="{{(index .NetworkSettings.Networks \"${1}\").IPAddress}}" "${2}"
