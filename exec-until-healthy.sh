#!/usr/bin/env bash

set -eu

wait_for_healthy() {
    while ! docker compose exec -T ipa /usr/bin/systemctl status ipa > /dev/null 2>&1
    do
        sleep 10
    done

    kill $pid
}

pid=$$
wait_for_healthy &
"${@}"
