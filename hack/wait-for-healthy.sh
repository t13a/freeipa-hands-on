#!/bin/sh

set -eu

wait_for_healthy() {
    while ! docker compose ps "${1}" | grep -q '(healthy)' > /dev/null 2>&1
    do
        sleep 10
    done

    kill $pid
}

pid=$$
wait_for_healthy "${1}" &
sleep 1
shift
"${@}"
