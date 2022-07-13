#!/bin/env bash

set -e

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
NAMESPACE_DIR="$(realpath "${SCRIPTS_DIR}/../namespace")"

NS="$("${NAMESPACE_DIR}"/shortcut-to-ns.sh ${1} )"
FILTER="${FILTER:-}"
WATCH_IMPL="${WATCH_IMPL:-watch}" # alternatives: viddy

if ! type "${WATCH_IMPL}" &> /dev/null; then
    echo "${WATCH_IMPL} command is required"
    exit 1
fi

COMMAND="oc get pods -owide"

if [[ -n "${NS}" ]]; then
    COMMAND="${COMMAND} -n ${NS}"
fi

if [[ -n "${FILTER}" ]]; then
    COMMAND="${COMMAND} | grep -v ${FILTER}"
fi

"${WATCH_IMPL}" -n 1 "${COMMAND}"

