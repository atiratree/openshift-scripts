#!/bin/env bash

set -e

KUBECONFIGS="/tmp/kubeconfigs"

if [[ -z "$1" ]]; then
  echo "kubeconfig path must be specified!"
  exit 1
fi

KUBECONFIG_PATH="$(realpath $1)"
OVERWRITE_LAST="${OVERWRITE_LAST:-}"

if [[ "${1}" == "zreset" ]]; then
  rm "${KUBECONFIGS}"/* 2>/dev/null
  # needs to be sourced for this to work
  unset KUBECONFIG
  unset KUBEADMIN_PASSWORD
  exit 0
fi

resolveNextNumber() {
  set +e
  LAST_NUM="$(ls $KUBECONFIGS 2>/dev/null | tail -1 | grep -Eo "[1-9][0-9]*")"
  set -e
  if [[ -z "${LAST_NUM}" ]]; then
    NEXT_NUM="1"
  elif [[ "${OVERWRITE_LAST}" == "true" ]]; then
    NEXT_NUM="${LAST_NUM}"
  else
    NEXT_NUM="$((${LAST_NUM}+1))"
  fi
  
  # format as 05
  if [[ -n "${LAST_NUM}" ]]; then
    LAST_NUM="$(printf "%02d" ${LAST_NUM})"
  fi
  if [[ -n "${NEXT_NUM}" ]]; then
    NEXT_NUM="$(printf "%02d" ${NEXT_NUM})"
  fi
}

mkdir -p "${KUBECONFIGS}"

resolveNextNumber
NEXT_KUBECONFIG="${KUBECONFIGS}/kubeconfig-${NEXT_NUM}"
NEXT_KUBEADMIN_PASSWORD="${KUBECONFIGS}/kubeadmin-password-${NEXT_NUM}"

if [[ -n "${LAST_NUM}" ]] && [[ "$(readlink -f "${KUBECONFIGS}/kubeconfig-${LAST_NUM}")" == "${KUBECONFIG_PATH}" ]]; then
  exit 0 # don't repeat the same entries
fi


if [[ "${OVERWRITE_LAST}" == "true" ]]; then
    rm -f "${NEXT_KUBECONFIG}" "${NEXT_KUBEADMIN_PASSWORD}"    
fi

ln -s "${KUBECONFIG_PATH}" "${NEXT_KUBECONFIG}"

if [[ -n "$2" ]]; then
  # create a real file for the password in the same location as kubeconfig
  echo "$2" > "${KUBECONFIG_PATH}-kubeadmin-password"
fi

if [[ -f "${KUBECONFIG_PATH}-kubeadmin-password" ]]; then
  ln -s "${KUBECONFIG_PATH}-kubeadmin-password" "${NEXT_KUBEADMIN_PASSWORD}"
else
  CONF_DIR="$(dirname "${KUBECONFIG_PATH}")"
  if [[ -f "${CONF_DIR}/kubeadmin-password" ]]; then
    ln -s "${CONF_DIR}/kubeadmin-password" "${NEXT_KUBEADMIN_PASSWORD}"
  else
    # default to empty, maybe password will appear later
    touch "${NEXT_KUBEADMIN_PASSWORD}"
  fi
fi


export KUBECONFIG="${NEXT_KUBECONFIG}"
export KUBEADMIN_PASSWORD="$(cat "${NEXT_KUBEADMIN_PASSWORD}")"

if [[ -z "${KUBEADMIN_PASSWORD}" ]]; then
  unset KUBEADMIN_PASSWORD
fi


