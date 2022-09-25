# https://awsjp.com/AWS/hikaku/paravirtualPV-Hardware-assistedVM-compare.html
# virtualization_type 準仮想化:paravirtual 完全仮想化:hvm
resource "aws_ami_copy" "aws_handson_ec2_ami_copy" {
  name         = "aws-handson-ec2-ami-copy"
  description  = "a copy of ec2 instance"
  source_ami_id      = var.ami
  source_ami_region  = var.region
   tags = {
    Name = "aws-handson-ec2-ami-copy"
  }
}
