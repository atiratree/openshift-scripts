#!/bin/env bash

set -e

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"

ACCESS_TOKEN="$("${SCRIPTS_DIR}/get-token.sh")"

oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge

IN_CLUSTER_IMAGE_REGISTRY="image-registry.openshift-image-registry.svc:5000"
IMAGE_REGISTRY="$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')"
FORWARDED_IMAGE_REGISTRY="localhost:5000"
# docker need to be used with: oc port-forward --namespace openshift-image-registry service/image-registry 5000:5000


echo "podman authenticating:"
if ! type podman &> /dev/null; then
  echo "podman not found: skipping..." >&2
else
  podman login --tls-verify=false -u kubeadmin -p "${ACCESS_TOKEN}" "${IMAGE_REGISTRY}"
fi

echo "docker authenticating:"
if ! type docker &> /dev/null; then
  echo "docker not found: skipping..." >&2
else
  set +e
    docker login -u kubeadmin -p "${ACCESS_TOKEN}" "${FORWARDED_IMAGE_REGISTRY}"
    EXIT_CODE=$?

    if [[ ${EXIT_CODE} -ne 0 ]]; then
        echo "for docker login please use oc port-forward --namespace openshift-image-registry service/image-registry 5000:5000"
    fi

    exit ${EXIT_CODE}
  set -e
fi

