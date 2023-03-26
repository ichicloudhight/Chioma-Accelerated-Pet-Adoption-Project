# create KeyPair 
resource "tls_private_key" "client1_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "client1_prv" {
  content  = tls_private_key.client1_key.private_key_pem
  filename = "client1_prv"
}


resource "aws_key_pair" "client1_pub_key" {
  key_name   = "client1_pub_key"
  public_key = tls_private_key.client1_key.public_key_openssh
}