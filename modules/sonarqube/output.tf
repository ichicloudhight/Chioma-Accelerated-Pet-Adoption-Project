utput "sonarqube_IP" {
  value       = aws_instance.client1_sonarqube.public_ip
  description = "sonarqube public IP"
}