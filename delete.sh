#!/bin/sh
set -euo pipefail

. env

terraform init -upgrade
terraform destroy -auto-approve \
    -var hostname="${VAR_HOSTNAME}" \
    -var unixname="${VAR_UNIXNAME}" \
    -var ssh_key_name="${VAR_SSH_KEY_NAME}"

rm -f inventory.ini
