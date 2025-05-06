#!/bin/env bash

set -e

NS="${1:-}"

case "$NS" in
    # cluster-kube-apiserver-operator
    kaso) NS=openshift-kube-apiserver-operator ;;
    kas) NS=openshift-kube-apiserver ;;
    # cluster-kube-controller-manager-operator
    kcmo) NS=openshift-kube-controller-manager-operator ;;
    kcm) NS=openshift-kube-controller-manager ;;
    # cluster-kube-scheduler-operator 
    kso) NS=openshift-kube-scheduler-operator ;;
    ks) NS=openshift-kube-scheduler ;;
    # cluster-openshift-apiserver-operator
    oaso) NS=openshift-apiserver-operator ;;
    oas) NS=openshift-apiserver ;;
    # cluster-openshift-controller-manager-operator
    ocmo) NS=openshift-controller-manager-operator ;;
    ocm) NS=openshift-controller-manager ;;
    # openshift-route-controller-manager
    rcm) NS=openshift-route-controller-manager ;;
    # etcd-operator
    etcdo) NS=openshift-etcd-operator ;;
    etcd) NS=openshift-etcd ;;
    # openshift-monitoring
    monitoring) NS=openshift-monitoring ;;
    # cluster-authentication-operator
    autho) NS=openshift-authentication-operator ;;
    # oauth-apiserver
    authas) NS=openshift-oauth-apiserver ;;
    # run-once-duration-override-operator
    rodoo) NS=run-once-duration-override-operator ;;
    # run-once-duration-override
    rodo) NS=run-once-duration-override-operator ;;
    # jobset-operator
    jso) NS=openshift-jobset-operator ;;
    # cluster-kube-descheduler-operator
    *) ;;
esac

if [[ -n "${NS}" ]]; then
  echo "${NS}"
fi
