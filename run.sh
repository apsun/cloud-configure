#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"

VAR_DOMAIN_NAME=crossbowffs.com
VAR_HOSTNAME=kosuzu
VAR_UNIXNAME=admin
VAR_SSH_KEY_NAME=sachi-linux
VAR_ENABLE_SSL=

terraform() {
    command terraform -chdir="${SCRIPT_DIR}" "$@"
}

apply() {
    terraform init -upgrade
    terraform apply \
        -var hostname="${VAR_HOSTNAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}"
    ansible
}

destroy() {
    terraform init -upgrade
    ansible dns/dns.yaml -e enable_dns=
    terraform destroy \
        -var hostname="${VAR_HOSTNAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}"
}

refresh() {
    terraform init -upgrade
    terraform refresh \
        -var hostname="${VAR_HOSTNAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}"
}

ip() {
    terraform output --raw node_public_ip
}

ssh() {
    command ssh "${VAR_UNIXNAME}@$(ip)" "$@"
}

ansible() {
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook "${1:-ansible.yaml}" \
        -i "$(ip)," \
        -u "${VAR_UNIXNAME}" \
        -e "hostname=${VAR_HOSTNAME}" \
        -e "domain_name=${VAR_DOMAIN_NAME}" \
        -e "enable_ssl=${VAR_ENABLE_SSL}" \
        "${@:2}"
}

"$@"
