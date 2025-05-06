#!/bin/env bash

set -e


# fallback to incoming shortcut, as multiple shortcuts can have the same namespace
COMPONENT_SHORTCUT="${1:-}"

case "$COMPONENT_SHORTCUT" in
    # kaso cluster-kube-apiserver-operator
    openshift-kube-apiserver-operator) COMPONENT_SHORTCUT=kaso ;;
    openshift-kube-apiserver) COMPONENT_SHORTCUT=kas ;;
    # kcmo cluster-kube-controller-manager-operator
    openshift-kube-controller-manager-operator) COMPONENT_SHORTCUT=kcmo ;;
    openshift-kube-controller-manager) COMPONENT_SHORTCUT=kcm ;;
    # kso cluster-kube-scheduler-operator
    openshift-kube-scheduler-operator) COMPONENT_SHORTCUT=kso ;;
    openshift-kube-scheduler) COMPONENT_SHORTCUT=ks ;;
    # oaso cluster-openshift-apiserver-operator
    openshift-apiserver-operator) COMPONENT_SHORTCUT=oaso ;;
    openshift-apiserver) COMPONENT_SHORTCUT=oas ;;
    # ocmo cluster-openshift-controller-manager-operator
    openshift-controller-manager-operator) COMPONENT_SHORTCUT=ocmo ;;
    openshift-controller-manager) COMPONENT_SHORTCUT=ocm ;;
    # openshift-route-controller-manager
    openshift-route-controller-manager) COMPONENT_SHORTCUT=rcm ;;
    # etcdo etcd-operator
    openshift-etcd-operator) COMPONENT_SHORTCUT=etcdo ;;
    openshift-etcd) COMPONENT_SHORTCUT=etcd ;;
    # monitoring openshift-monitoring
    openshift-monitoring) COMPONENT_SHORTCUT=monitoring ;;
    # cluster-authentication-operator
    openshift-authentication-operator) COMPONENT_SHORTCUT=autho ;;
    # oauth-apiserver
    openshift-oauth-apiserver) COMPONENT_SHORTCUT=authas ;;
    # run-once-duration-override-operator
    run-once-duration-override-operator) COMPONENT_SHORTCUT=rodoo ;;
    # jobset-operator
    openshift-jobset-operator) COMPONENT_SHORTCUT=jso ;;

    # cluster-kube-descheduler-operator
    *) ;;
esac

if [[ -n "${COMPONENT_SHORTCUT}" ]]; then
  echo "${COMPONENT_SHORTCUT}"
fi
