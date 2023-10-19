#!/bin/env bash

set -e

COMPONENT_SHORTCUT="${1:-}"
POD_NAME=""

case "$COMPONENT_SHORTCUT" in
    # kaso cluster-kube-apiserver-operator
    kaso) POD_NAME=kube-apiserver-operator ;;
    kas) POD_NAME=kube-apiserver ;;
    # kcmo cluster-kube-controller-manager-operator
    kcmo) POD_NAME=kube-controller-manager-operator ;;
    kcm) POD_NAME=kube-controller-manager ;;
    # kso cluster-kube-scheduler-operator
    kso) POD_NAME=openshift-kube-scheduler-operator ;;
    ks) POD_NAME=openshift-kube-scheduler ;;
    # oaso cluster-openshift-apiserver-operator
    oaso) POD_NAME=openshift-apiserver-operator ;;
    oas) POD_NAME=apiserver ;;
    # ocmo cluster-openshift-controller-manager-operator
    ocmo) POD_NAME=openshift-controller-manager-operator ;;
    ocm) POD_NAME=controller-manager ;;
    # rcm openshift-route-controller-manager
    rcm) POD_NAME=route-controller-manager ;;
    # etcdo etcd-operator
    etcdo) POD_NAME=etcd-operator ;;
    etcd) POD_NAME=etcd ;;
    # monitoring openshift-monitoring
    monitoring) POD_NAME=prometheus-k8s ;;
    # autho cluster-authentication-operator
    autho) POD_NAME=authentication-operator ;;
    # authas oauth-apiserver
    authas) POD_NAME=apiserver ;;
    # rodoo run-once-duration-override-operator
    rodoo) POD_NAME=run-once-duration-override-operator ;;
    # rodo run-once-duration-override
    rodo) POD_NAME=runoncedurationoverride ;;

    # cluster-kube-descheduler-operator
    *) ;;
esac

if [[ -n "${POD_NAME}" ]]; then
  echo "${POD_NAME}"
fi
