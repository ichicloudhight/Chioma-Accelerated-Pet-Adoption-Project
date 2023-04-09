locals {
  docker_user_data = <<-EOF
#!/bin/bash
sudo yum update -y 
echo "***********Install python for docker and docker***********"
sudo yum upgrade -y
sudo yum install python3 python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo pip3 install docker-py
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli -y
## Enable and start docker engine and assign user 
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
## Install New relic
echo "license_key: eu01xx7f52e170948bda373b5b56692bc00aNRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y 
## Changing ssh configs
sudo su
echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
sudo service sshd reload
chmod -R 700 .ssh/
sudo chmod 600 .ssh/authorized_keys
echo "****************Change Hostname(IP) to something readable**************"
sudo hostnamectl set-hostname Docker
sudo reboot
EOF

}