#!/bin/env bash

set -e

INSTALLER_DIR="${INSTALLER_DIR:-}"
RELEASE_GRAPH_FILE="$(mktemp)"
CHANNEL=${1:-4.20.0-0.ci} # 4.20.0-0.nightly
DOWNGRADE="${DOWNGRADE:-0}"

trap cleanup INT TERM EXIT

function cleanup() {
  rm -f "${RELEASE_GRAPH_FILE}"
}

function mvsafe() {
  if [[ -e "${1}" ]]; then
    mv "${1}" "${2}"
  fi
}

if [[ -z "${INSTALLER_DIR}" ]]; then
  echo "INSTALLER_DIR env var is required" >&2
  exit 1
fi


LATEST_RELEASES="$(curl -s 'https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/graph' | jq '.nodes[] | select(.version|test("'"${CHANNEL}"'"))| .version' | sort -r | sed 's/"//g')"

curl -s 'https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/graph?format=dot' > "${RELEASE_GRAPH_FILE}"

RELEASE=""

set +e

for release in ${LATEST_RELEASES}; do
  FOUND_NON_REJECTED="$(grep ${release} "${RELEASE_GRAPH_FILE}" | grep -v "color=red")"
  FOUND_SUCCESS="$(curl -s "https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/releasestream/${CHANNEL}/release/$release" | grep "oc adm release extract")"
  if [[ -n "${FOUND_NON_REJECTED}" ]] && [[ -n "${FOUND_SUCCESS}" ]]; then
    if [[ "${DOWNGRADE}" -eq 0 ]]; then
      RELEASE="${release}"
      break
    else
      DOWNGRADE_CURRENT="${DOWNGRADE}"
      DOWNGRADE="$(( "${DOWNGRADE}" - 1 ))"
    fi
    echo "skipping $release (downgrade ${DOWNGRADE_CURRENT})"
  else
    echo "skipping $release"
  fi
done


if [[ -z "${RELEASE}" ]]; then
  echo "release not found: failed releases: ${LATEST_RELEASES}" >&2
  exit 1
fi

pushd "${INSTALLER_DIR}"
  if [[ -f ./bin/openshift-install ]] && [[ $(./bin/openshift-install version) =~ ${RELEASE} ]]; then
    echo "installer is already at latest version ${RELEASE}"
    exit 0
  fi


  echo "downloading ${RELEASE} release..."

  set -e
  oc adm release extract --tools "registry.ci.openshift.org/ocp/release:${RELEASE}"
  set +e

  mvsafe ./bin/openshift-install openshift-install.bak
  tar -xzf "openshift-install-linux-${RELEASE}.tar.gz"
  rm  "openshift-install-linux-${RELEASE}.tar.gz"
  mv ./openshift-install ./bin/openshift-install

  mvsafe ./oc ./oc.bak
  mvsafe ./kubectl ./kubectl.bak
  tar -xzf "openshift-client-linux-${RELEASE}.tar.gz"
  rm "openshift-client-linux-${RELEASE}.tar.gz"

  mvsafe ./ccoctl ./ccoctl.bak
  tar -xzf "ccoctl-linux-${RELEASE}.tar.gz"
  rm "ccoctl-linux-${RELEASE}.tar.gz"
popd
