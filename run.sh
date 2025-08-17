#!/bin/bash
set -euo pipefail

VAR_DOMAIN_NAME=crossbowffs.net
VAR_HOSTNAME=minori
VAR_STATIC_IP_NAME=
VAR_TEMP_STATIC_IP_NAME=minori-ip
VAR_SSH_KEY_NAME=andrew-sachiko
VAR_LIGHTSAIL=true
VAR_UNIXNAME=admin
VAR_ENABLE_SSL=true

apply() {
    terraform apply \
        -var hostname="${VAR_HOSTNAME}" \
        -var static_ip_name="${VAR_STATIC_IP_NAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}" \
        -var lightsail="${VAR_LIGHTSAIL}"
    refresh -auto-approve
    _ansible dns/dns.yaml
    _ansible
}

destroy() {
    _ansible dns/dns.yaml -e enable_dns=
    terraform destroy \
        -var hostname="${VAR_HOSTNAME}" \
        -var static_ip_name="${VAR_STATIC_IP_NAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}" \
        -var lightsail="${VAR_LIGHTSAIL}"
}

refresh() {
    terraform apply -refresh-only \
        -var hostname="${VAR_HOSTNAME}" \
        -var static_ip_name="${VAR_STATIC_IP_NAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}" \
        -var lightsail="${VAR_LIGHTSAIL}" \
        "$@"
}

newip() {
    refresh
    terraform apply -auto-approve \
        -var hostname="${VAR_HOSTNAME}" \
        -var static_ip_name="${VAR_TEMP_STATIC_IP_NAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}" \
        -var lightsail="${VAR_LIGHTSAIL}"
    terraform apply -auto-approve \
        -var hostname="${VAR_HOSTNAME}" \
        -var static_ip_name="${VAR_STATIC_IP_NAME}" \
        -var ssh_key_name="${VAR_SSH_KEY_NAME}" \
        -var lightsail="${VAR_LIGHTSAIL}"
    refresh -auto-approve
    _ansible dns/dns.yaml
}

_ip() {
    terraform output --raw node_public_ip
}

ssh() {
    refresh
    command ssh "${VAR_UNIXNAME}@$(_ip)" "$@"
}

_ansible() {
    ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_GATHERING=explicit ansible-playbook "${1:-ansible.yaml}" \
        -i "$(_ip)," \
        -u "${VAR_UNIXNAME}" \
        -e "$(jq -n '$ARGS.named' \
            --arg hostname "${VAR_HOSTNAME}" \
            --arg domain_name "${VAR_DOMAIN_NAME}" \
            --argjson enable_ssl "${VAR_ENABLE_SSL}"
        )"
        "${@:2}"
}

ansible() {
    refresh
    _ansible "$@"
}

cd "$(dirname "$0")"
terraform init -upgrade
"$@"
