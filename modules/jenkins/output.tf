output "jenkins_IP" {
  value       = aws_instance.client1_jenkins.public_ip
  description = "jenkins public IP"
}