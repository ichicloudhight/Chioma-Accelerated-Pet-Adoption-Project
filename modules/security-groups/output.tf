output "ansible_sg" {
  value = aws_security_group.client1_ansible_sg.id
}

output "bastion_sg" {
  value = aws_security_group.client1_bastion_sg.id
}

output "jenkins_sg" {
  value = aws_security_group.client1_jenkins_sg.id
}

output "HAproxy_sg" {
  value = aws_security_group.client1_HAproxy_sg.id
}