terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48"
    }
  }
}

variable "hostname" {
  type = string
}

variable "unixname" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

provider "aws" {
  region  = "us-west-2"
  profile = "terraform"
}

/*
resource "aws_instance" "node" {
  ami                         = "ami-0b8db56f1634f78b5"
  instance_type               = "t3.small"
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true
  tags = {
    Name = var.hostname
  }
}

output "node_public_ip" {
  value = aws_instance.node.public_ip
}
*/

resource "aws_lightsail_instance" "node" {
  name              = var.hostname
  availability_zone = "us-west-2a"
  blueprint_id      = "debian_11"
  bundle_id         = "small_2_0"
  key_pair_name     = var.ssh_key_name
}

resource "aws_lightsail_instance_public_ports" "node" {
  instance_name = aws_lightsail_instance.node.name

  port_info {
    protocol  = "all"
    from_port = 0
    to_port   = 65535
  }
}

output "node_public_ip" {
  value = aws_lightsail_instance.node.public_ip_address
}
