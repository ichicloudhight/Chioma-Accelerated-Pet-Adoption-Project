locals {
  jenkins_user_data = <<-EOF
#!/bin/bash
sudo yum update -y

echo "***********Install required plugins***********"
sudo yum install wget -y
sudo yum install git -y
sudo yum install maven -y

echo "***********Install Java JDK***********"
sudo yum install java-11-openjdk -y

echo "***********Install Jenkins***********"
sudo wget https://get.jenkins.io/redhat/jenkins-2.346-1.1.noarch.rpm
sudo rpm -ivh jenkins-2.346-1.1.noarch.rpm
sudo yum install jenkins 
sudo systemctl daemon-reload

#Enable and start jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "***********Install Docker Engine***********"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl enable docker
sudo systemctl start docker

#change docker user
sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user

# #changing ssh configs
# sudo service sshd restart
# sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'


echo "***********private key in new file***********"
cat <<EOT>> /home/ec2-user/.ssh/jenkins_rsa
${var.prv_key}
EOT

#Change .ssh permission and ownership
sudo chmod -R 700 .ssh/
sudo chown -R ec2-user:ec2-user .ssh/

echo "****************Change Hostname(IP) to something readable**************"
sudo hostnamectl set-hostname Jenkins
sudo reboot
EOF
}