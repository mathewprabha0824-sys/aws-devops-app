output "web1_public_ip" {
  value = aws_instance.web1.public_ip
}

output "web2_public_ip" {
  value = aws_instance.web2.public_ip
}

output "app1_private_ip" {
  value = aws_instance.app1.private_ip
}

output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}