#create sonarqube server
resource "aws_instance" "client1_sonarqube" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.client1_pub_sn2.id
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.client1_sonarqube_sg.id}"]
  key_name                    = aws_key_pair.client1_pub_key.key_name
  user_data                   = local.sonarqube_user_data


  tags = {
    Name = "client1_sonarqube"
  }
}