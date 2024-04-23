resource "aws_vpc" "main" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
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

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "Mysg" {
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Mysg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_sg_ipv4" {
  security_group_id = aws_security_group.Mysg.id
  cidr_ipv4         = var.sgcidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_sg1_ipv4" {
  security_group_id = aws_security_group.Mysg.id
  cidr_ipv4         = var.sgcidr
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
  bucket = "t-erraform2024project"
}

resource "aws_instance" "web" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Mysg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))

  tags = {
    Name = "T-form1"
  }
}

resource "aws_instance" "web1" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Mysg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))

  tags = {
    Name = "T-form2"
  }
}





