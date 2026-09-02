# Fetch latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu_24" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-practice-sg"
  description = "Allow Kubernetes required ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Master Node
############################################
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = var.master_instance_type
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.root_volume_size_master
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              curl -sfL https://get.k3s.io | K3S_TOKEN=${var.k3s_token} sh -
              hostnamectl set-hostname master-node
              EOF

  tags = {
    Name = "master-node"
  }
}

############################################
# Worker Nodes
############################################
resource "aws_instance" "worker" {
  count                  = var.worker_count
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = var.worker_instance_type
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name

  depends_on = [aws_instance.master]

  root_block_device {
    volume_size = var.root_volume_size_worker
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              sleep 60
              curl -sfL https://get.k3s.io | \
              K3S_URL=https://${aws_instance.master.private_ip}:6443 \
              K3S_TOKEN=${var.k3s_token} sh -
              hostnamectl set-hostname worker-node-${count.index + 1}
              EOF

  tags = {
    Name = "worker-node-${count.index + 1}"
  }
}