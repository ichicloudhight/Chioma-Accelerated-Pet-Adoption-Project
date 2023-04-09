#create ansible server 
resource "aws_instance" "client1_ansible" {
  ami                         = "ami-09744628bed84e434"
  instance_type               = var.instance_type
  subnet_id                   = var.client1pubsub1_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.ansible_sg]
  key_name                    = var.keypair
  #iam_instance_profile = aws_iam_instance_profile.client1-IAM-profile.id
  user_data                   = local.ansible_user_data
  # # Connection Through SSH
  # connection {
  #   type        = "ssh"
  #   private_key = (var.prv_key)
  #   user        = "ec2-user"
  #   host        = self.public_ip
  # }

tags = {
    Name = "client1_ansible"
  }

}