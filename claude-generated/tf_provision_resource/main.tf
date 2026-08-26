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

  owners = ["136693071363"] # Debian
}

resource "aws_key_pair" "kthw" {
  key_name   = "kubernetes-the-hard-way"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_security_group" "kthw" {
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

resource "aws_instance" "machine" {
  for_each = var.machines

  ami                    = data.aws_ami.debian_12.id
  instance_type          = each.value.instance_type
  key_name               = aws_key_pair.kthw.key_name
  subnet_id              = aws_subnet.kthw.id
  vpc_security_group_ids = [aws_security_group.kthw.id]

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
  }
}

resource "aws_eip" "machine" {
  for_each = var.machines

  instance = aws_instance.machine[each.key].id
  domain   = "vpc"

  depends_on = [aws_internet_gateway.kthw]

  tags = {
    Name = each.key
  }
}
