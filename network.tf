# VPC
resource "aws_vpc" "aws_handson_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "aws-handson-vpc"
  }
}
# �p�u���b�N�T�u�l�b�g
resource "aws_subnet" "aws_handson_public_subnet_1a" {
  vpc_id                  = aws_vpc.aws_handson_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-handson-public-subnet-1a"
  }
}
resource "aws_subnet" "aws_handson_public_subnet_1c" {
  vpc_id                  = aws_vpc.aws_handson_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-handson-public-subnet-1c"
  }
}
# �v���C�x�[�g�T�u�l�b�g
resource "aws_subnet" "aws_handson_private_subnet_1a" {
  vpc_id                  = aws_vpc.aws_handson_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false 

  tags = {
    Name = "aws-handson-private-subnet-1a"
  }
}
resource "aws_subnet" "aws_handson_private_subnet_1c" {
  vpc_id                  = aws_vpc.aws_handson_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false 

  tags = {
    Name = "aws-handson-private-subnet-1c"
  }
}
# �C���^�[�l�b�g�Q�[�g�E�F�C
resource "aws_internet_gateway" "aws_handson_igw" {
  vpc_id = aws_vpc.aws_handson_vpc.id

  tags = {
    Name = "aws-handson-igw"
  }
}
# �p�u���b�N
# ���[�g�e�[�u��
resource "aws_route_table" "aws_handson_route_table" {
  vpc_id = aws_vpc.aws_handson_vpc.id

  tags = {
    Name = "aws-handson-route-table"
  }
}
# ���[�g
resource "aws_route" "aws_handson_route" {
  route_table_id         = aws_route_table.aws_handson_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_handson_igw.id
}
# ���[�g�e�[�u���Ƃ̊֘A�t��
resource "aws_route_table_association" "aws_handson_route_table_a" {
  route_table_id = aws_route_table.aws_handson_route_table.id
  subnet_id      = aws_subnet.aws_handson_public_subnet_1a.id
}
