output "rds_endpoint" {
 value = aws_db_instance.aws_handson_rds.endpoint 
}
output "elb_dnsname" {
 value = "http://${aws_lb.aws_handson_lb.dns_name}"
}
