# セキュリティグループ
resource "aws_security_group" "aws_handson_rds_sg" {
  name        = "aws-handson-rds-sg"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.aws_handson_vpc.id
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    // ec2セキュリティグループが紐づくリソースにアクセス許可
    security_groups = [aws_security_group.aws_handson_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "aws-handson-rds-sg"
  }
}

# サブネットグループ
resource "aws_db_subnet_group" "aws_handson_rds_subnet_group" {
    name        = "aws-handson-rds-subnet-group"
    subnet_ids  = [
        aws_subnet.aws_handson_private_subnet_1a.id,
        aws_subnet.aws_handson_private_subnet_1c.id
    ]
    tags = {
        Name = "aws-handson-rds-subnet-group"
    }
}

# 日本語DOC https://runebook.dev/ja/docs/terraform/providers/aws/d/db_instance
resource "aws_db_instance" "aws_handson_rds" {
  # identifer RDS インスタンス名
  identifier              = "aws-handson-rds-wp-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  storage_type            = "gp2"
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  # default port          = 3306
  option_group_name       = aws_db_option_group.aws_handson_rds_option_group.name
  parameter_group_name    = aws_db_parameter_group.aws_handson_rds_parameter_group.name
  db_subnet_group_name    = aws_db_subnet_group.aws_handson_rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aws_handson_rds_sg.id]
  multi_az                = false
  allocated_storage       = 20
  availability_zone       = "ap-northeast-1a"
  # DB削除前にスナップショットを作成しない
  skip_final_snapshot = true
  # 自動スケーリング上限
  max_allocated_storage = 1000

  tags = {
    Name = "aws-handson-rds-wp-db"
  }
}

# RDS DB Option Gruop
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MySQL.Options.html
resource "aws_db_option_group" "aws_handson_rds_option_group" {
  name                 = "aws-handson-rds-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

# RDS DB Parameter Group
# family とは? dbパラメータのグループを指定しているのか？
# param ref https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Reference.html
resource "aws_db_parameter_group" "aws_handson_rds_parameter_group" {
  name   = "aws-handson-rds-parameter-group"
  family = "mysql8.0"
}
