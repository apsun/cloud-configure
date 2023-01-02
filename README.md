# cloud-configure

This repo contains the automation for provisioning my personal server. It uses
[Terraform](https://www.terraform.io/) to create a new AWS EC2/Lightsail
instance, and [Ansible](https://www.ansible.com/) to configure the software on
that instance.

## Environment assumptions

Some playbooks read secrets from [`pass`](https://www.passwordstore.org/),
e.g. `wireguard/<peer name>`, `ssh/<public key name>`.

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

You need to have a Cloudflare API token with Zone.DNS:Edit permissions stored
in `pass` at `cloudflare.com/edit-dns-api-token`.

## Usage

To create a new server instance:

```Bash
./run.sh apply
```

Note: the `aws_lightsail_instance_public_ports` resource is a bit buggy and
will try to re-create the association every time you run `apply`. This won't
affect the instance itself; just the firewall rule.

To delete the server instance:

```Bash
./run.sh destroy
```

To re-run Ansible after making changes:

```Bash
./run.sh ansible  # run all playbooks (excluding dns)
./run.sh ansible <playbook> [ansible-playbook args]  # run a specific playbook
```

SSL is disabled by default (to avoid getting rate-limited by letsencrypt when
repeatedly creating and destroying new instances). To enable it, set
`VAR_ENABLE_SSL=` to a non-empty value and run Ansible again.

If you stop the instance and are not using a static IP, it might lose its
public IP address. When this happens, run `apply` again.
