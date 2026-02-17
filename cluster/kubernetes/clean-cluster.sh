#!/bin/env bash

echo "killing k8s"

KILL_EXTRA_ARGS=""


if [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]] || [[ "$1" == "--force-kill" ]]; then
    KILL_EXTRA_ARGS="-9"
fi
sudo  kill $KILL_EXTRA_ARGS `pgrep -f "${HOME}"/go/src/k8s.io/kubernetes/_output/local/bin`
sudo  kill $KILL_EXTRA_ARGS `pgrep -f "${HOME}"/go/src/k8s.io/kubernetes/_output/bin`
sudo  kill $KILL_EXTRA_ARGS `pgrep -f etcd`

echo "removing files"
sudo rm -vrf /var/run/kubernetes/
sudo rm -vrf /tmp/kube-apiserver-audit.log \
    /tmp/kube-apiserver.log \
    /tmp/kube-audit-policy-file \
    /tmp/kube-controller-manager.log \
    /tmp/kube-proxy.log \
    /tmp/kube-proxy.yaml \
    /tmp/kube-scheduler.log \
    /tmp/kube-scheduler.yaml \
    /tmp/kube-serviceaccount.key \
    /tmp/kubelet.log \
    /tmp/kubelet.yaml \
    /tmp/etcd.log \
    /tmp/hostpath_pv


if [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]]; then
    echo "using --force to remove installed/cached files"
    sudo rm -vrf /opt/cni
    sudo rm -vrf /etc/cni/net.d
    sudo rm -rf "${HOME}"/go/src/k8s.io/kubernetes/_output
    sudo rm -rf "${HOME}"/go/src/k8s.io/kubernetes/_tmp
fi


echo "restarting containerd"
sudo systemctl restart containerd.service && sudo chmod 666 /run/containerd/containerd.sock
