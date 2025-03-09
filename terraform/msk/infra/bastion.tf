resource "aws_security_group" "bastion" {
  name   = "${var.project_name}-sg-bastion"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    to_port     = "22"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = "${var.project_name}-keypair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "keypair" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "./temp/keypair.pem"
}

resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-role-bastion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachments_exclusive" "bastion" {
  role_name = aws_iam_role.bastion.name
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-role-bastion"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  subnet_id            = module.vpc.public_subnets[0]
  security_groups      = [aws_security_group.bastion.id]
  ami                  = data.aws_ami.al2023.id
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name             = aws_key_pair.keypair.key_name
  instance_type = "t4g.small"

  # user_data = file("./userdata.sh")

  tags = {
    Name = "${var.project_name}-bastion"
  }

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
}

output "bastion_ip" {
  value = aws_eip.bastion.address
}
