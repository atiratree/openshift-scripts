#!/bin/env bash

set -e

API_URL="$(oc whoami  --show-server)"

KUBEADMIN_PASSWORD=${KUBEADMIN_PASSWORD:-}

if [[ -z "${KUBEADMIN_PASSWORD}" ]]; then
    echo "KUBEADMIN_PASSWORD not found!" >&2
    exit 1
fi

DOMAIN_URL="$(echo "${API_URL}" | sed 's/^.*api.//;s/:.*$//')"
AUTHORIZE_URL="https://oauth-openshift.apps.${DOMAIN_URL}/oauth/authorize?client_id=openshift-challenging-client&response_type=token"

ACCESS_TOKEN="$(curl  -u "kubeadmin:${KUBEADMIN_PASSWORD}" -H "X-CSRF-Token: ${RANDOM}"  -vk "${AUTHORIZE_URL}" 2>&1 | grep -Eo 'access_token=[^&]+' | sed 's/access_token=//')"

if [[ -z "${ACCESS_TOKEN}" ]]; then
    # possibly failed auth - show result
    curl  -u "kubeadmin:${KUBEADMIN_PASSWORD}" -H "X-CSRF-Token: ${RANDOM}"  -vk "${AUTHORIZE_URL}"
    exit 2
else
    echo "${ACCESS_TOKEN}"
fi
