#!/bin/env bash

set -e

API_TOKEN="${1}"

if [[ -z "${API_TOKEN}" ]]; then
    xdg-open "https://oauth-openshift.apps.ci.l2s4.p1.openshiftapps.com/oauth/token/request"
    echo "API token is required!" >&2
    exit 1
fi

GITHUB_USER="${GITHUB_USER:-}"

if [[ -z "${GITHUB_USER}" ]]; then
  echo "GITHUB_USER env var is required" >&2
  exit 1
fi

REGISTRY_URL="${REGISTRY_URL:-registry.ci.openshift.org}"
AUTH_INFO="${GITHUB_USER}:${API_TOKEN}"
AUTH_INFO_BASE64="$(echo -n "${AUTH_INFO}" | base64 -w 0)"

INSTALL_CONFIG="${INSTALL_CONFIG:-"${HOME}/work/conf/ocpcred/install-config.yaml"}"
PULL_SECRET="${PULL_SECRET:-"${HOME}/work/conf/ocpcred/openshift-installer-pull-secret.txt"}"

if [[ -f "${INSTALL_CONFIG}" ]]; then
  # make backup first
  cp "${INSTALL_CONFIG}" "${INSTALL_CONFIG}~"

  # update install config
  LAST_AUTH="$(yq '.pullSecret' "${INSTALL_CONFIG}" | sed -e 's;\\;;g' -e 's/^"//' -e 's/"$//' | jq '.auths."registry.ci.openshift.org".auth' |  sed -e 's/^"//' -e 's/"$//')"

  sed -i "s/${LAST_AUTH}/${AUTH_INFO_BASE64}/g" "${INSTALL_CONFIG}"

  echo "updated install config"
fi

if [[ -f "${PULL_SECRET}" ]]; then
  # update pull secret
  LAST_AUTH="$(jq '.auths."registry.ci.openshift.org".auth' "${PULL_SECRET}" |  sed -e 's/^"//' -e 's/"$//')"
  sed -i "s/${LAST_AUTH}/${AUTH_INFO_BASE64}/g" "${PULL_SECRET}"

  echo "updated pull secret"
fi


# try logging in

podman login "${REGISTRY_URL}" -u "${GITHUB_USER}" -p "${API_TOKEN}"

docker login "${REGISTRY_URL}" -u "${GITHUB_USER}" -p "${API_TOKEN}"
