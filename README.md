# OpenShift and Kubernetes scripts

## Usage

Create aliases for the scripts and put them in your `.bashrc`/`.zshrc`

```bash
alias logs="/path/to/watch/logs.sh"
alias pods="FILTER=Completed /path/to/watch/pods.sh"
alias podss="/path/to/watch/pods.sh"
```

Use shortcuts instead of writing the full namespace

```bash
pods kcmo
logs kas
```
