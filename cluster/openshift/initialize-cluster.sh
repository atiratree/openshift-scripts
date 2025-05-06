#!/bin/env bash

set -e

pruneCert() {
  if [[ -z ${1} ]]; then
    return
  fi
  for certCA in "/etc/ca-certificates/trust-source/${1}"*.p11-kit; do
    if [[ -f "${certCA}" ]]; then
      sudo trust anchor --remove "${certCA}"
    fi
  done
}

pruneCerts() {
  pruneCert "ingress-operator_"
  pruneCert "kube-apiserver-"
  pruneCert "openshift-kube-apiserver-"
  pruneCert "_.apps.${CLUSTER_NAME}.group-b.devcluster.openshift.com"
  pruneCert "_.apps.ci-ln-"

  sudo update-ca-trust
}

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
AUTH_DIR="$(realpath "${SCRIPTS_DIR}/../../auth")"

CLUSTER_NAME=${1:-clustername}

DISABLE_CVO=${DISABLE_CVO:-false}

if ! oc get namespace test > /dev/null 2>&1; then
    oc new-project test > /dev/null
fi


if [[ "${DISABLE_CVO}" == true ]]; then
    # disable CVO
    if [[ "$(oc get -n openshift-cluster-version deployments/cluster-version-operator -o "jsonpath={.spec.replicas}")" != "0" ]]; then
        oc scale --replicas 0 -n openshift-cluster-version deployments/cluster-version-operator
    fi
fi

read -p "Press enter to update certs and login to openshift registry"


# update certificate trust store - was tested only on Arch
if cat /etc/*release | grep -oq "Arch Linux"; then
    pruneCerts

    # trust cluster CAs for apiserver, console, prometheus, etc.
    oc get cm -n openshift-kube-controller-manager serviceaccount-ca -o jsonpath='{.data.ca-bundle\.crt}' > cluster_ca_bundle.crt
    sudo trust anchor --store cluster_ca_bundle.crt
    rm cluster_ca_bundle.crt

    sudo update-ca-trust
fi


# login to openshift registry with podman and docker
"${AUTH_DIR}/login-registry.sh"
