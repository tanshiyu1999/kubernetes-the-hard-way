variable "region" {
  description = "AWS region to provision the Kubernetes the Hard Way machines in."
  type        = string
  default     = "ap-southeast-1"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the machines (e.g. \"YOUR_PUBLIC_IP/32\"). Do not leave as 0.0.0.0/0."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key to install on each machine."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vpc_cidr" {
  description = "CIDR block for the Kubernetes the Hard Way VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet the machines are launched into."
  type        = string
  default     = "10.0.1.0/24"
}

# Mirrors the machine database schema from docs/03-compute-resources.md:
# IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
variable "machines" {
  description = "Machines to provision for the tutorial."
  type = map(object({
    instance_type = string
    volume_size   = number
    pod_subnet    = optional(string)
  }))

  default = {
    jumpbox = {
      instance_type = "t3.micro"
      volume_size   = 10
    }
    server = {
      instance_type = "t3.small"
      volume_size   = 20
    }
    "node-0" = {
      instance_type = "t3.small"
      volume_size   = 20
      pod_subnet    = "10.200.0.0/24"
    }
    "node-1" = {
      instance_type = "t3.small"
      volume_size   = 20
      pod_subnet    = "10.200.1.0/24"
    }
  }
}
