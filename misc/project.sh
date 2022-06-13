#!/bin/env bash

set -e

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
NAMESPACE_DIR="$(realpath "${SCRIPTS_DIR}/../namespace")"

NS="$("${NAMESPACE_DIR}"/shortcut-to-ns.sh ${1} )"

oc project "$NS"
