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

resource "aws_instance" "node" {
  ami                         = "ami-0208c4ce9b9b6b33c"
  instance_type               = "t4g.nano"
  key_name                    = var.ssh_key_name
  count                       = 1
  user_data_replace_on_change = true
  user_data                   = <<EOT
#cloud-config
hostname: ${var.hostname}
system_info:
  default_user:
    name: ${var.unixname}
EOT

  tags = {
    Name = "node_${count.index}"
  }
}

output "node_public_ip" {
  value = aws_instance.node[*].public_ip
}
