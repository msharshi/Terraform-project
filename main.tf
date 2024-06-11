resource "aws_vpc" "main" {
  cidr_block = var.cidr

}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "Mysg" {
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Mysg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_sg_ipv4" {
  security_group_id = aws_security_group.Mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_sg1_ipv4" {
  security_group_id = aws_security_group.Mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.Mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-harshith-bucket"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = "my-terraform-harshith-bucket"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_instance" "web1" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Mysg.id]
  subnet_id              = aws_subnet.sub1.id
  key_name               = "ubu-key"


  tags = {
    Name = "Terraform-Project"
  }
}
