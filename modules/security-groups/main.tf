# Create Ansible Security Group
resource "aws_security_group" "client1_ansible_sg" {
  name        = "client1-ansible-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    cidr_blocks = ["*****/32"]    # my computer IP address
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
    security_group = [var.jenkins_lb_sg]    # security group attached to load balancer
  }

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    security_group = [aws_security_group.client1_bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "client1_jenkins_sg"
  }
}


# Create docker-prod security group
resource "aws_security_group" "client1_docker_sg" {
  name        = "client1_docker_sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.client1_vpc.id

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

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [var.docker-prod-lb-sg]  # the security group attached to docker-prod load balancer
  }
  
  ingress {
    description = "APPLICATION"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [var.docker-prod-lb-sg]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "client1_docker_sg"
  }
}


# Create docker-stage security group
resource "aws_security_group" "client1_dockerstage_sg" {
  name        = "client1_docker_sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.client1_vpc.id

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

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [var.docker-stage-lb-sg]  # the security group attached to docker-stage load balancer
  }
  
  ingress {
    description = "APPLICATION"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [var.docker-stage-lb-sg]  
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
  vpc_id      = aws_vpc.client1_vpc.id

  ingress {
    description = "proxy traffic"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["197.210.79.184/32"]    # my computer IP address
  }

  ingress {
    description = "Allow ssh traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["197.210.79.184/32"]    # my computer IP address
  }

ingress {
    description = "SSH"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.client1_jenkins_sg.id] 


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
}