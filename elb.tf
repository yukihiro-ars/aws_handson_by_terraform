# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "aws_handson_lb_target_group" {
  name        = "aws-handson-lb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws_handson_vpc.id
  # default protocol_version = "HTTP1"
  health_check {
    path = var.helthcheck_path
    # ���̓f�t�H���g�Ȃ̂ŕύX���Ȃ�
  }
  # target group �ɓo�^����EC2�C���X�^���X���w�肷����@
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "aws_handson_lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.aws_handson_lb_target_group.arn
  target_id        = aws_instance.aws_handson_ec2.id
  port             = 80
}
# ELB �Z�L�����e�B�O���[�v
resource "aws_security_group" "aws_handson_lb_sg" {
  name        = "aws-handson-lb-sg"
  description = "LB Security Group"
  vpc_id      = aws_vpc.aws_handson_vpc.id
  ingress {
    from_port = 80 
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "aws-handson-lb-sg"
  }
}
# ���[�h�o�����T(ALB)
resource "aws_lb" "aws_handson_lb" {
  name     = "aws-handson-lb"
  load_balancer_type = "application"
  internal = false
  ip_address_type = "ipv4"
  # DEMO�̂��ߏ�ɍ폜�ی얳����
  enable_deletion_protection = false
  security_groups = [aws_security_group.aws_handson_lb_sg.id]
  subnets = [
    aws_subnet.aws_handson_public_subnet_1a.id,
    aws_subnet.aws_handson_public_subnet_1c.id,
  ]
}
# ���[�h�o�����T���X�i�[
resource "aws_lb_listener" "aws_handson_lb_listener" {
  load_balancer_arn = aws_lb.aws_handson_lb.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.aws_handson_lb_target_group.id
    type             = "forward"
  }
}
