#!/bin/env bash

set -e

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
NAMESPACE_DIR="$(realpath "${SCRIPTS_DIR}/../namespace")"

NS="$("${NAMESPACE_DIR}"/shortcut-to-ns.sh ${1} )"
POD_NAME="$("${NAMESPACE_DIR}"/main-pod-name.sh ${NS} )"
NS_SHORT="$("${NAMESPACE_DIR}"/ns-to-shortcut.sh ${NS} )"
CONTAINER="${CONTAINER:-}"
NOVIS="${NOVIS:-}" # no visualization in lnav

if [[ -z "${NS}" ]]; then
    echo "namespace required" >&2
    exit 1
fi

if [[ -z "${NS_SHORT}" ]]; then
    echo "namespace shortcut required" >&2
    exit 1
fi

if [[ -z "${POD_NAME}" ]]; then
    echo "pod name required" >&2
    exit 1
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
RESULT_DIR="/tmp/${NS_SHORT}_${timestamp}"

mkdir -p "${RESULT_DIR}"


echo "following..."

for pod in ${PODS}; do
    CONTAINERS="${CONTAINER}"
    if [[ -z "${CONTAINER}" ]]; then
        CONTAINERS=$(kubectl get pods -n ${NS} ${pod} -o jsonpath='{.spec.containers[*].name}')
    fi
    for container in ${CONTAINERS}; do
        log_file="${RESULT_DIR}/${NS_SHORT}_${timestamp}_${pod}_${container}"
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
