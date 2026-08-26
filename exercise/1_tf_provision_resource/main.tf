
// AWS will return one matching AMI, and hold the actual AMI id in .id
data "aws_ami" "debian_12" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Anyone can upload an AMI, so we filter by offical Debian owner.
  owners = ["136693071363"] # Debian
}

# ssh-keygen -t ed25519 -f ~/.ssh/kthw -C "kubernetes-the-hard-way"
# ^ Creates the key pair so I can use it to SSH into the machines. The public key is uploaded to AWS, and the private key is used to connect to the machines.
resource "aws_key_pair" "kthw" {
  key_name   = "kubernetes-the-hard-way"
  public_key = file(var.ssh_public_key_path)
}

# Creating a new security group
resource "aws_security_group" "kthw" {
  # Creating security group for the machines to allow SSH and inter-node traffic. The security group is attached to the VPC created above.
  name        = "kubernetes-the-hard-way"
  description = "Kubernetes the Hard Way - jumpbox/server/node SSH and inter-node traffic"
  vpc_id      = aws_vpc.kthw.id

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "All traffic between cluster machines (etcd, API server, kubelet, pod routes)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating the instances
resource "aws_instance" "machine" {
  for_each = var.machines

  ami           = data.aws_ami.debian_12.id
  instance_type = each.value.instance_type
  # The key is uploaded to AWS
  # When this instance boots, the public key is installed in 
  # /home/admin/.ssh/authorized_keys (pulled from AWS with this refernce)
  key_name = aws_key_pair.kthw.key_name
  # Put it in the subnet
  subnet_id = aws_subnet.kthw.id
  # Apply the security group
  vpc_security_group_ids = [aws_security_group.kthw.id]

  # Runs once on first boot (cloud-init). 
  # user_data is a TF resource argument that is passed to the instance at launch.
  user_data = <<-EOF
    #!/bin/bash
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    mkdir -p /root/.ssh
    cp /home/admin/.ssh/authorized_keys /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    systemctl restart sshd
  EOF

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
  }
}

# Elastic IP, these gets attached 
resource "aws_eip" "machine" {
  for_each = var.machines

  instance = aws_instance.machine[each.key].id
  domain   = "vpc"

  depends_on = [aws_internet_gateway.kthw]

  tags = {
    Name = each.key
  }
}
