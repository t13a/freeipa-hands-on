#!/bin/sh

set -eu

while true
do
    case "${1}" in
        --)
            break
            ;;
        *)
            set -a
            source "$(realpath "${1}")"
            set +a
            shift
            ;;
    esac
done

exec "${@}"
