#!/bin/sh
set -euo pipefail

. env

terraform init -upgrade
terraform apply -auto-approve \
    -var hostname="${VAR_HOSTNAME}" \
    -var unixname="${VAR_UNIXNAME}" \
    -var ssh_key_name="${VAR_SSH_KEY_NAME}"

cat > inventory.ini <<EOF
[all]
$(terraform output -json node_public_ip | jq -r '.[]')

[all:vars]
ansible_user=${VAR_UNIXNAME}
domain_name=${VAR_DOMAIN_NAME}
EOF

ansible-playbook -i inventory.ini ansible.yaml
