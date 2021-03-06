#!/bin/env bash

set -e

NS="${1:-}"
POD_NAME=""

case "$NS" in
    # kaso cluster-kube-apiserver-operator
    openshift-kube-apiserver-operator) POD_NAME=kube-apiserver-operator ;;
    openshift-kube-apiserver) POD_NAME=kube-apiserver ;;
    # kcmo cluster-kube-controller-manager-operator
    openshift-kube-controller-manager-operator) POD_NAME=kube-controller-manager-operator ;;
    openshift-kube-controller-manager) POD_NAME=kube-controller-manager ;;
    # kso cluster-kube-scheduler-operator
    openshift-kube-scheduler-operator) POD_NAME=openshift-kube-scheduler-operator ;;
    openshift-kube-scheduler) POD_NAME=openshift-kube-scheduler ;;
    # oaso cluster-openshift-apiserver-operator
    openshift-apiserver-operator) POD_NAME=openshift-apiserver-operator ;;
    openshift-apiserver) POD_NAME=apiserver ;;
    # ocmo cluster-openshift-controller-manager-operator
    openshift-controller-manager-operator) POD_NAME=openshift-controller-manager-operator ;;
    openshift-controller-manager) POD_NAME=controller-manager ;;
    # etcdo etcd-operator
    openshift-etcd-operator) POD_NAME=etcd-operator ;;
    openshift-etcd) POD_NAME=etcd ;;

    # cluster-kube-descheduler-operator
    *) ;;
esac

if [[ -n "${POD_NAME}" ]]; then
  echo "${POD_NAME}"
fi
