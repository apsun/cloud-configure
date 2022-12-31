#!/bin/sh
set -euo pipefail

VAR_DOMAIN_NAME=crossbowffs.com
VAR_HOSTNAME=kosuzu
VAR_UNIXNAME=admin
VAR_SSH_KEY_NAME=sachi-linux

apply() {
    terraform init -upgrade
    terraform apply -auto-approve \
        -var hostname="${VAR_HOSTNAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}"
    ansible
}

destroy() {
    terraform init -upgrade
    terraform destroy -auto-approve \
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
        "${@:2}"
}

"$@"
