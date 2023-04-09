#create sonarqube server
resource "aws_instance" "client1_sonarqube" {
  ami                         = "ami-09744628bed84e434"
  instance_type               = "t2.medium"
  subnet_id                   = var.client1pubsub1_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sonarqube_sg]
  key_name                    = var.keypair
  user_data                   = local.sonarqube_user_data


  tags = {
    Name = "client1_sonarqube"
  }
}