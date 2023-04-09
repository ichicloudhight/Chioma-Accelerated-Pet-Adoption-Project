#create Docker stage server 
resource "aws_instance" "client1_dockerstage" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.client1pubsub1_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.dockerstage_sg]
  key_name                    = var.keypair
  user_data                   = local.docker_user_data

  tags = {
    Name = "client1_dockerstage"
  }
}

data "aws_instance" "client1_dockerstage" {
  filter {
    name   = "tag:Name"
    values = ["client1_dockerstage"]
  } 
  depends_on = [
    aws_instance.client1_dockerstage
  ]
}
    


#create Docker prod server 
resource "aws_instance" "client1_dockerprod" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.client1pubsub1_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.dockerprod_sg]
  key_name                    = var.keypair
  user_data                   = local.docker_user_data

  tags = {
    Name = "client1_dockerprod"
  }
}

data "aws_instance" "client1_dockerprod" {
  filter {
    name   = "tag:Name"
    values = ["client1_dockerprod"]
  }
  depends_on = [
    aws_instance.client1_dockerprod
  ]
}


