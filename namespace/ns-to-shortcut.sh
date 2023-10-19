#!/bin/env bash

set -e

NS="${1:-}"
NS_SHORT=""

case "$NS" in
    # kaso cluster-kube-apiserver-operator
    openshift-kube-apiserver-operator) NS_SHORT=kaso ;;
    openshift-kube-apiserver) NS_SHORT=kas ;;
    # kcmo cluster-kube-controller-manager-operator
    openshift-kube-controller-manager-operator) NS_SHORT=kcmo ;;
    openshift-kube-controller-manager) NS_SHORT=kcm ;;
    # kso cluster-kube-scheduler-operator
    openshift-kube-scheduler-operator) NS_SHORT=kso ;;
    openshift-kube-scheduler) NS_SHORT=ks ;;
    # oaso cluster-openshift-apiserver-operator
    openshift-apiserver-operator) NS_SHORT=oaso ;;
    openshift-apiserver) NS_SHORT=oas ;;
    # ocmo cluster-openshift-controller-manager-operator
    openshift-controller-manager-operator) NS_SHORT=ocmo ;;
    openshift-controller-manager) NS_SHORT=ocm ;;
    # openshift-route-controller-manager
    openshift-route-controller-manager) NS_SHORT=rcm ;;
    # etcdo etcd-operator
    openshift-etcd-operator) NS_SHORT=etcdo ;;
    openshift-etcd) NS_SHORT=etcd ;;
    # monitoring openshift-monitoring
    openshift-monitoring) NS_SHORT=monitoring ;;    
    # cluster-authentication-operator
    openshift-authentication-operator) NS_SHORT=autho ;;
    # oauth-apiserver
    openshift-oauth-apiserver) NS_SHORT=authas ;;
    # run-once-duration-override-operator
    run-once-duration-override-operator) NS_SHORT=rodoo ;;
    # run-once-duration-override
    run-once-duration-override) NS_SHORT=rodo ;;

    # cluster-kube-descheduler-operator
    *) ;;
esac

if [[ -n "${NS_SHORT}" ]]; then
  echo "${NS_SHORT}"
fi
