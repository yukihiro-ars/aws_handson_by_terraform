# �Z�L�����e�B�O���[�v
resource "aws_security_group" "aws_handson_ec2_sg" {
  name        = "aws-handson-ec2-sg"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.aws_handson_vpc.id

  tags = {
    Name = "aws-handson-ec2-sg"
  }
}
# �O������HTTP80�|�[�g�ւ̒ʐM������
resource "aws_security_group_rule" "aws_handson_ec2_in_http" {
  security_group_id = aws_security_group.aws_handson_ec2_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}
# ELB ������
resource "aws_security_group_rule" "aws_handson_ec2_in_http_lb" {
  security_group_id = aws_security_group.aws_handson_ec2_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  source_security_group_id = aws_security_group.aws_handson_lb_sg.id
}
# Web�T�[�o�[����O���ւ̒ʐM�����@�S�J��
resource "aws_security_group_rule" "aws_handson_ec2_out" {
  security_group_id = aws_security_group.aws_handson_ec2_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
# EC2�C���X�^���X 
# user data�̓n���Y�I���ɋL�ڂ����̂܂�
resource "aws_instance" "aws_handson_ec2" {
  instance_type = "t2.micro"
  ami           = var.ami
  subnet_id     = aws_subnet.aws_handson_public_subnet_1a.id
  vpc_security_group_ids = [
    aws_security_group.aws_handson_ec2_sg.id,
  ]
  user_data = file("ins_wp.sh")
  tags = {
    Name = "aws-handson-ec2"
  }
}
