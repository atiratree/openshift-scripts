#!/bin/env bash

set -e

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
NAMESPACE_DIR="$(realpath "${SCRIPTS_DIR}/../namespace")"

NS="$("${NAMESPACE_DIR}"/shortcut-to-ns.sh ${1} )"
FILTER="${FILTER:-}"

if [[ -z "$NS" ]]; then
    if [[ -z "$FILTER" ]]; then
        watch -n 1  "oc get pods -owide"
    else
        watch -n 1  "oc get pods -owide | grep -v ${FILTER}"
    fi
else
    if [[ -z "$FILTER" ]]; then
        watch -n 1  "oc get pods -owide -n $NS"
    else
        watch -n 1  "oc get pods -owide -n $NS | grep -v ${FILTER}"
    fi
fi
