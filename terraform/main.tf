provider "aws" {
  region = var.region
}

resource "aws_key_pair" "k8s" {
  key_name   = var.key_name
  public_key = file("C:/Users/senth/.ssh/k8s.pub")
}

resource "aws_security_group" "k8s" {
  name = "k8s-sg"

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

resource "aws_instance" "control_plane" {
  ami                    = "ami-00d8fc944fb171e29" # ubuntu-noble-24.04-amd64-server-20251022
  instance_type          = var.instance_type
  key_name               = aws_key_pair.k8s.key_name
  vpc_security_group_ids = [aws_security_group.k8s.id]

  tags = {
    Name = "k8s-control-plane"
  }
}


resource "aws_instance" "workers" {
  count                  = 2
  ami                    = aws_instance.control_plane.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.k8s.key_name
  vpc_security_group_ids = [aws_security_group.k8s.id]

  tags = {
    Name = "k8s-worker-${count.index}"
  }
}
