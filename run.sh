#!/bin/sh
set -euo pipefail

VAR_DOMAIN_NAME=crossbowffs.com
VAR_HOSTNAME=kosuzu
VAR_UNIXNAME=andrew
VAR_SSH_KEY_NAME=sachi-linux

apply() {
    terraform init -upgrade
    terraform apply -auto-approve \
        -var hostname="${VAR_HOSTNAME}" \
        -var unixname="${VAR_UNIXNAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}"
    ansible
}

destroy() {
    terraform init -upgrade
    terraform destroy -auto-approve \
        -var hostname="${VAR_HOSTNAME}" \
        -var unixname="${VAR_UNIXNAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}"
}

ip() {
    terraform output -json node_public_ip | jq -r '.[]'
}

ssh() {
    command ssh "${VAR_UNIXNAME}@$(ip | head -n1)" "$@"
}

ansible() {
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook "${1:-ansible.yaml}" \
        -i "$(ip | paste -sd,)," \
        -u "${VAR_UNIXNAME}" \
        -e "domain_name=${VAR_DOMAIN_NAME}"
}

"$@"
