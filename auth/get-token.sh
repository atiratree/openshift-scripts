#!/bin/env bash

set -e

ACCESS_TOKEN=""

tokenOpenShift(){
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
    fi
}

tokenKube(){
    # Create a secret to hold a token for the default service account
    kubectl apply -f - > /dev/null <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: default-token
  annotations:
    kubernetes.io/service-account.name: default
type: kubernetes.io/service-account-token
EOF

    # Wait for the token controller to populate the secret with a token:
    while ! kubectl describe secret default-token | grep -E '^token' >/dev/null; do
      echo "waiting for token..." >&2
      sleep 1
    done

    # Get the token value
    ACCESS_TOKEN=$(kubectl get secret default-token -o jsonpath='{.data.token}' | base64 --decode)

}


if oc whoami >/dev/null 2>&1; then
    tokenOpenShift
else
    tokenKube
fi


if [[ -z "${ACCESS_TOKEN}" ]]; then
    echo "could not obtain access token!" >&2
    exit 2
else
    echo "${ACCESS_TOKEN}"
fi
