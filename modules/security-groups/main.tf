# Create Ansible Security Group
resource "aws_security_group" "client1_ansible_sg" {
  name        = "client1_ansible_sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip]
  }

  tags = {
    Name = "client1_ansible_sg"
  }
}



# Security group for Bastion Host
resource "aws_security_group" "client1_bastion_sg" {
  name        = "client1_bastion_sg"
  description = "Allow traffic for ssh"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow ssh traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]    # my computer IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip]
  }

  tags = {
    Name = "client1_bastion_sg"
  }
}

resource "aws_security_group" "client1_jenkins_sg" {
  name        = "client1_jenkins_sg"
  description = "Allow Jenkins traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Proxy Traffic"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]    # security group attached to load balancer
  }

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "client1_jenkins_sg"}
}


# Create docker-prod security group
resource "aws_security_group" "client1_dockerprod_sg" {
  name        = "client1_dockerprod_sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id


  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  ingress {
    description = "Proxy access"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

   
   ingress {
     description = "APPLICATION"
     from_port   = 8080
     to_port     = 8080
     protocol    = "tcp"
     #cidr_blocks = [var.docker-prod-lb-sg]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "client1_dockerprod_sg"
  }
}


# Create docker-stage security group
resource "aws_security_group" "client1_dockerstage_sg" {
  name        = "client1_dockerstage_sg"
  description = "Allow inbound traffic"
  vpc_id      =  var.vpc_id

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    security_groups = [aws_security_group.client1_bastion_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    security_groups = [aws_security_group.client1_ansible_sg.id]
  }

   
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "client1_dockerstage_sg"
  }
}


# Create Sonarqube Security Group
resource "aws_security_group" "client1_sonarqube_sg" {
  name        = "client1_sonarqube_sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id


  ingress {
    description = "sonarqube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]    # my computer IP address
  }

  ingress {
    description = "Allow ssh traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]    # my computer IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "client1_sonarqube_sg"
   }
}
