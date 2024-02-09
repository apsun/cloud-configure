terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "hostname" {
  type        = string
  description = "hostname of the created instance"
}

variable "static_ip_name" {
  type        = string
  default     = ""
  description = "static IP name (Lightsail) or elastic IP allocation ID (EC2)"
}

variable "ssh_key_name" {
  type        = string
  description = "ssh key pair name (must already exist in Lightsail/EC2)"
}

variable "lightsail" {
  type        = bool
  default     = true
  description = "whether to create the instance in Lightsail or EC2"
}

provider "aws" {
  region  = "us-west-2"
  profile = "terraform"
}

resource "aws_instance" "node" {
  ami                         = "ami-0e3fabf7e6603a437"
  instance_type               = "t4g.small"
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true
  count                       = !var.lightsail ? 1 : 0
  tags = {
    Name = var.hostname
  }
  lifecycle {
    ignore_changes = [
      key_name,
    ]
  }
}

resource "aws_eip_association" "node" {
  instance_id   = aws_instance.node[0].id
  allocation_id = var.static_ip_name
  count         = (!var.lightsail && var.static_ip_name != "") ? 1 : 0
}

resource "aws_lightsail_instance" "node" {
  name              = var.hostname
  availability_zone = "us-west-2a"
  blueprint_id      = "debian_11"
  bundle_id         = "small_2_0"
  key_pair_name     = var.ssh_key_name
  count             = var.lightsail ? 1 : 0
  lifecycle {
    ignore_changes = [
      key_pair_name,
    ]
  }
}

resource "aws_lightsail_static_ip_attachment" "node" {
  static_ip_name = var.static_ip_name
  instance_name  = aws_lightsail_instance.node[0].id
  count          = (var.lightsail && var.static_ip_name != "") ? 1 : 0
}

resource "aws_lightsail_instance_public_ports" "node" {
  instance_name = aws_lightsail_instance.node[0].name
  count         = var.lightsail ? 1 : 0
  port_info {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535
    cidrs = [
      "0.0.0.0/0",
    ]
    ipv6_cidrs = [
      "::/0",
    ]
  }
  port_info {
    protocol  = "udp"
    from_port = 0
    to_port   = 65535
    cidrs = [
      "0.0.0.0/0",
    ]
    ipv6_cidrs = [
      "::/0",
    ]
  }
}

output "node_public_ip" {
  value = (
    var.lightsail ?
    aws_lightsail_instance.node[0].public_ip_address :
    aws_instance.node[0].public_ip
  )
}
