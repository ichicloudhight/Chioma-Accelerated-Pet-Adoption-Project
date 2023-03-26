output "ansible_IP" {
  value       = aws_instance.client1_ansible.public_ip
  description = "Ansible public IP"
}