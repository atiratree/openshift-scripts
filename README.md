# OpenShift scripts


## Prerequisites

- oc

### Optional

- podman or docker
- viddy
- lnav

## Usage

Create aliases for the scripts and put them in your `.bashrc`/`.zshrc`

```bash
alias logs="/path/to/watch/logs.sh"
alias pods="WATCH_IMPL=viddy FILTER=Completed /path/to/watch/pods.sh"
alias podss="WATCH_IMPL=viddy /path/to/watch/pods.sh"
alias podsy="OUTPUT_TYPE=yaml WATCH_IMPL=viddy FILTER=Completed /path/to/watch/pods.sh"
alias gettoken="/path/to/auth/get-token.sh"
alias project="/path/to/misc/project.sh"
```

Use shortcuts instead of writing the full namespace

```bash
pods kcmo
logs kas
project ks
```

### Cluster Management

```bash
alias createcluster='export KUBECONFIG=${HOME}/work/clusters/cluster0/auth/kubeconfig; cp ${HOME}/work/{conf/ocpcred/install-config.yaml,clusters/cluster0/}; AWS_PROFILE=openshift-group-b openshift-install create cluster --dir ${HOME}/work/clusters/cluster0/ --log-level=debug; export KUBEADMIN_PASSWORD="$(cat ${HOME}/work/clusters/cluster0/auth/kubeadmin-password)"; DISABLE_CVO=false ${HOME}/path/to/openshift-scripts/cluster/openshift/initialize-cluster.sh username-cluster0'
alias destroycluster='AWS_PROFILE=openshift-group-b openshift-install destroy cluster --dir ${HOME}/work/clusters/cluster0/ --log-level=debug; unset KUBECONFIG; unset KUBEADMIN_PASSWORD; ${HOME}/path/to/openshift-scripts/cluster/openshift/clean-after-deleted-cluster.sh username'
```
