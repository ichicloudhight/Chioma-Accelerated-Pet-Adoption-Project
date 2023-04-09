output "Docker_IP" {
  value       = aws_instance.client1_dockerstage.public_ip
  description = "Docker public IP"
}

output "Dockerprod_IP" {
  value       = aws_instance.client1_dockerprod.public_ip
  description = "Docker public IP"
}