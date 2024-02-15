# cloud-configure

This repo contains the automation for provisioning my personal server. It uses
[Terraform](https://www.terraform.io/) to create a new AWS EC2/Lightsail
instance, and [Ansible](https://www.ansible.com/) to configure the software on
that instance.

## Environment assumptions

You need to have an AWS IAM user named `terraform` configured with the
appropriate permissions (`ec2:*` if creating an EC2 instance, or `lightsail:*`
if creating a Lightsail instance). The auth keys should be stored in
`~/.aws/credentials`, i.e:

```INI
[terraform]
aws_access_key_id = XXX
aws_secret_access_key = YYY
```

The public ssh key referenced by `VAR_SSH_KEY_NAME` needs to already be
uploaded to EC2/Lightsail in the appropriate region.

If `VAR_STATIC_IP_NAME` is non-empty, it needs to reference an existing
elastic IP allocation ID (EC2) or static IP name (Lightsail). The IP is not
managed by Terraform and will not be automatically destroyed.

SSL can be disabled by setting `VAR_ENABLE_SSL` to an empty value. This can
be useful to avoid getting rate-limited by letsencrypt when repeatedly
creating and destroying new instances.

Some playbooks read secrets from [`pass`](https://www.passwordstore.org/),
e.g. `wireguard/<peer name>`, `ssh/<public key name>`.

You need to have a Cloudflare API token with Zone.DNS:Edit permissions stored
in `pass` at `cloudflare.com/${VAR_DOMAIN_NAME}-edit-dns-api-token`.

You need to have an email address used to register with letsencrypt stored in
`pass` at `letsencrypt.org/email`.

## Usage

To create a new server instance or re-apply all changes (including Ansible):

```Bash
./run.sh apply
```

To delete the server instance:

```Bash
./run.sh destroy
```

To re-run Ansible after making changes to a playbook:

```Bash
./run.sh ansible  # run all playbooks (excluding dns)
./run.sh ansible <playbook/playbook.yaml> [ansible-playbook args]  # run a specific playbook
```

To request a new public IP address for your instance, set the
`VAR_TEMP_STATIC_IP_NAME` variable to an existing unused static IP name,
and run:

```Bash
./run.sh newip
```

This will attach and then detach the static IP from the instance, which
will result in it receiving a new IP address. You can also manually stop
and restart the instance.

If you manually edit instance properties externally, you can manually refresh
the Terraform state and apply DNS settings:

```Bash
./run.sh refresh
./run.sh ansible dns/dns.yaml
```
