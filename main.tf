resource "aws_vpc" "main" {
  cidr_block = var.address_space
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)

  tags = {
    Name = "${var.prefix}-subnet"
  }
}

resource "aws_security_group" "main" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.prefix}-rtb"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {  
  key_name   = var.prefix
  public_key = tls_private_key.main.public_key_openssh
}

#resource "local_file" "main" {
#  content  = tls_private_key.main.private_key_pem
#  filename = "${path.module}/${var.prefix}.pem"
#  file_permission = "0400"
#}

data "aws_ami" "main" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.main.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "${var.prefix}-instance"
  }
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain = "vpc"
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main.id
}
