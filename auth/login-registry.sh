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
podman login --tls-verify=false -u kubeadmin -p "${ACCESS_TOKEN}" "${IMAGE_REGISTRY}"

echo "docker authenticating:"
set +e
  docker login -u kubeadmin -p "${ACCESS_TOKEN}" "${FORWARDED_IMAGE_REGISTRY}"
  EXIT_CODE=$?
set -e

if [[ ${EXIT_CODE} -ne 0 ]]; then
    echo "for docker login please use oc port-forward --namespace openshift-image-registry service/image-registry 5000:5000"
fi

exit ${EXIT_CODE}
