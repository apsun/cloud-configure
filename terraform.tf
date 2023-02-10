terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54"
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
  ami                         = "ami-0208c4ce9b9b6b33c"
  instance_type               = "t4g.small"
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true
  count                       = !var.lightsail ? 1 : 0
  tags = {
    Name = var.hostname
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
    protocol  = "all"
    from_port = 0
    to_port   = 65535
  }
}

output "node_public_ip" {
  value = (
    var.lightsail ? (
      var.static_ip_name == "" ?
      aws_lightsail_instance.node[0].public_ip_address :
      aws_lightsail_static_ip_attachment.node[0].ip_address
      ) : (
      var.static_ip_name == "" ?
      aws_instance.node[0].public_ip :
      aws_eip_association.node[0].public_ip
    )
  )
}
