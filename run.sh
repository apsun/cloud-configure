#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"

VAR_DOMAIN_NAME=crossbowffs.net
VAR_HOSTNAME=minori
VAR_STATIC_IP_NAME=kosuzu-ip
VAR_SSH_KEY_NAME=sachi-linux
VAR_LIGHTSAIL=true
VAR_UNIXNAME=admin
VAR_ENABLE_SSL=1

terraform() {
    command terraform -chdir="${SCRIPT_DIR}" "$@"
}

apply() {
    terraform init -upgrade
    terraform apply \
        -var hostname="${VAR_HOSTNAME}" \
        -var static_ip_name="${VAR_STATIC_IP_NAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}" \
        -var lightsail="${VAR_LIGHTSAIL}"
    ansible dns/dns.yaml
    ansible
}

destroy() {
    terraform init -upgrade
    ansible dns/dns.yaml -e enable_dns=
    terraform destroy \
        -var hostname="${VAR_HOSTNAME}" \
        -var static_ip_name="${VAR_STATIC_IP_NAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}" \
        -var lightsail="${VAR_LIGHTSAIL}"
}

ip() {
    terraform output --raw node_public_ip
}

ssh() {
    command ssh "${VAR_UNIXNAME}@$(ip)" "$@"
}

ansible() {
    ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_GATHERING=explicit ansible-playbook "${1:-ansible.yaml}" \
        -i "$(ip)," \
        -u "${VAR_UNIXNAME}" \
        -e "hostname=${VAR_HOSTNAME}" \
        -e "domain_name=${VAR_DOMAIN_NAME}" \
        -e "enable_ssl=${VAR_ENABLE_SSL}" \
        "${@:2}"
}

"$@"
