#!/bin/env bash

set -e

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
NAMESPACE_DIR="$(realpath "${SCRIPTS_DIR}/../namespace")"

NS="$("${NAMESPACE_DIR}"/shortcut-to-ns.sh ${1} )"
COMPONENT_SHORTCUT="$("${NAMESPACE_DIR}"/ns-to-shortcut.sh ${1} )"
POD_NAME="$("${NAMESPACE_DIR}"/shortcut-to-main-pod-name.sh ${COMPONENT_SHORTCUT} )"
CONTAINER="${CONTAINER:-}"
NOVIS="${NOVIS:-}" # no visualization in lnav

if [[ -z "${NS}" ]]; then
    echo "namespace required" >&2
    exit 1
fi

if [[ -z "${COMPONENT_SHORTCUT}" ]]; then
    echo "namespace shortcut required" >&2
    exit 1
fi

if [[ -z "${POD_NAME}" ]]; then
    echo "pod name required" >&2
    exit 1
fi

if ! type lnav &> /dev/null; then
    echo "lnav command command not found: skipping visualisation" >&2
    NOVIS=true
fi

trap cleanup INT TERM EXIT

function cleanup() {
    processes=$(ps -O cmd | grep "oc logs -f -n ${NS} ${POD_NAME}" | grep -v grep | sed 's/^\s//' | cut -d' ' -f1)
    if [[ -n "${processes}" ]]; then
        kill -9 ${processes}
    fi
}

PODS="$(oc get pods -n ${NS} | grep Running | grep ${POD_NAME} | grep -v guard | cut -d' ' -f1)"
LOG_FILES=""

timestamp=$(date +'%FT%T')
RESULT_DIR="/tmp/${COMPONENT_SHORTCUT}_${timestamp}"

mkdir -p "${RESULT_DIR}"


echo "following..."

for pod in ${PODS}; do
    CONTAINERS="${CONTAINER}"
    if [[ -z "${CONTAINER}" ]]; then
        CONTAINERS=$(oc get pods -n ${NS} ${pod} -o jsonpath='{.spec.containers[*].name}')
    fi
    for container in ${CONTAINERS}; do
        log_file="${RESULT_DIR}/${COMPONENT_SHORTCUT}_${timestamp}_${pod}_${container}"
        oc logs -f -n ${NS} $pod -c $container  > $log_file &
        LOG_FILES="$LOG_FILES $log_file"
        echo $log_file
    done
done

if [[ -n "${NOVIS}" ]]; then
    sleep infinity
else
    lnav ${LOG_FILES}
fi
