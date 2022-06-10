# kconfig

## Usage

kconfig manages KUBECONFIG variables in all your terminals. Last used KUBECONFIG will be used in the next new terminal. All active KUBECONFIGS are stored in `/tmp/kubeconfigs` 

To choose a new  `KUBECONFIG` run (password is optional)

```bash
kconfig /path/to/new/kubeconfig password && kset
```

To switch to a new  `KUBECONFIG` in an old terminal run

```
kset
```

To unset `KUBECONFIG` and `KUBEADMIN_PASSWORD` variables

```
kclear
```

To remove all saved KUBECONFIGS

```
kset zreset
```

## Installation

Put this in your `.bashrc`/`.zshrc`

```bash
alias kconfig="/path/to/kconfig/kconfig.sh"

kset() {
  local KUBE_NUM="$(ls /tmp/kubeconfigs 2>/dev/null | tail -1 | grep -Eo "[0-9]*")"
  if [[ -z "${KUBE_NUM}" ]]; then
    for config in /path/to/clusters/cluster0/auth/kubeconfig \
             $(ls -t /tmp | grep -E "cluster-bot*" | head -1) \
             /var/run/kubernetes/admin.kubeconfig \
             /home/user/.kube/config; do
      if [[ -e "${config}" ]]; then
        /home/ansy/work/scripts/kconfig.sh "${config}"
        break
      fi
    done
  fi
  local KUBE_NUM="$(ls /tmp/kubeconfigs 2>/dev/null | tail -1 | grep -Eo "[0-9]*")"
  export KUBECONFIG="/tmp/kubeconfigs/kubeconfig-${KUBE_NUM}"
  export KUBEADMIN_PASSWORD="$(cat "/tmp/kubeconfigs/kubeadmin-password-${KUBE_NUM}" 2>/dev/null)"
  if [[ -z "${KUBEADMIN_PASSWORD}" ]]; then
    unset KUBEADMIN_PASSWORD
  fi
}

kclear() {
    unset KUBECONFIG
    unset KUBEADMIN_PASSWORD
}

kset

```
