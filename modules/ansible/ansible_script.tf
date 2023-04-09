locals {
  ansible_user_data = <<-EOF
#!/bin/bash
sudo apt-get update -y
sudo apt install docker.io -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible -y
echo "pubkeyAcceptKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
sudo systemctl reload sshd
sudo bash -c ' echo "strictHostKeyChecking No" >> /etc/ssh/ssh_config'
echo "${var.prv_key}" >> /home/ubuntu/.ssh/anskey_rsa
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/anskey_rsa 
sudo chgrp ubuntu:ubuntu /home/ubuntu/.ssh/anskey_rsa  
sudo chmod 400 /home/ubuntu/.ssh/anskey_rsa 
sudo echo "localhost ansible_connection=local" > /etc/ansible/hosts
sudo echo "[docker-stage]" >> /etc/ansible/hosts
sudo echo "${var.dockerstageIp} ansible_user=ec2-user ansible_ssh_private_key_file=/home/ubuntu/.ssh/anskey_rsa" >> /etc/ansible/hosts
sudo echo "[docker-prod]" >> /etc/ansible/hosts
sudo echo "${var.dockerprodIp} ansible_user=ec2-user ansible_ssh_private_key_file=/home/ubuntu/.ssh/anskey_rsa" >> /etc/ansible/hosts
sudo chown -R ubuntu:ubuntu /etc/ansible
sudo touch docker_image.yml docker_prod.yml docker_stage.yml dockerfile
echo "${file(var.docker-image)}" >> /etc/ansible/hosts/docker-image.yml
echo "${file(var.dockerstage-container)}" >> /etc/ansible/hosts/docker-stage.yml
echo "${file(var.dockerprod-container)}" >> /etc/ansible/hosts/docker-prod.yml
sudo mkdir /opt/docker
sudo chown -R ubuntu:ubuntu /opt/docker
sudo chmod -R 700 /opt/docker
touch /opt/docker/Dockerfile
cat <<EOT>> /opt/docker/Dockerfile
# pull tomcat image from docker hub
FROM tomcat
FROM openjdk:8-jre-slim
#copy war file on the container
COPY spring-petclinic-2.4.2.war app/
WORKDIR app/
RUN pwd
RUN ls -al
ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
EOT
 cat << EOT > /opt/docker/newrelic.yml
---
 - hosts: docker
   become: true
   tasks:
   - name: install newrelic agent
     command: docker run \
                     -d \
                     --name newrelic-infra \
                     --network=host \
                     --cap-add=SYS_PTRACE \
                     --privileged \
                     --pid=host \
                     -v "/:/host:ro" \
                     -v "/var/run/docker.sock:/var/run/docker.sock" \
                     -e NRIA_LICENSE_KEY=eu01xx7f52e170948bda373b5b56692bc00aNRAL \
                     newrelic/infrastructure:latest
EOT
sudo hostnamectl set-hostname Ansible
EOF
}




# locals {
#   ansible_user_data = <<-EOF
# #!/bin/bash
# sudo yum update -y
# sudo yum upgrade -y
# sudo yum install python3.8 -y
# sudo alternatives --set python /usr/bin/python3.8
# sudo yum -y install python3-pip
# sudo yum install ansible -y
# pip3 install ansible --user
# sudo chown ec2-user:ec2-user /etc/ansible
# #NEW RELIC SETUP
# echo "license_key: eu01xx1d1be02078413ea9369deaabc979e5NRAL" | sudo tee -a /etc/newrelic-infra.yml
# sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
# sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
# sudo yum install newrelic-infra -y
# echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/ssh_config.d/10-insecure-rsa-keysig.conf
# sudo service sshd reload
# sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
# echo "${var.prv_key}" >> /home/ec2-user/.ssh/anskey_rsa
# sudo chmod 400 anskey_rsa
# sudo chmod -R 700 .ssh/
# sudo chown -R ec2-user:ec2-user .ssh/
# sudo yum install -y yum-utils
# #DOCKER HUB CONFIGURATION
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum install docker-ce -y
# sudo systemctl start docker
# sudo usermod -aG docker ec2-user
# #CHANGE OWNERSHIP OF DIRECTORY TO EC2-USER
# cd /etc
# sudo chown ec2-user:ec2-user hosts
# cat <<EOT>> /etc/ansible/hosts
# localhost ansible_connection=local
# [docker_stage]
# ${var.dockerstageIp}  ansible_ssh_private_key_file=/home/ec2-user/.ssh/anskey_rsa
# [docker_prod]
# ${var.dockerprodIp}  ansible_ssh_private_key_file=/home/ec2-user/.ssh/anskey_rsa
# sudo touch docker_image.yml docker_prod.yml docker_stage.yml Dockerfile
# echo "${file(var.docker-image)}" >> /etc/ansible/hosts/docker-image.yml
# echo "${file(var.dockerstage-container)}" >> /etc/ansible/hosts/dockerstage-container.yml
# echo "${file(var.dockerprod-container)}" >> /etc/ansible/hosts/dockerprod-container.yml
# sudo mkdir /opt/docker
# sudo chown -R ec2-user:ec2-user /opt/docker
# sudo chmod -R 700 /opt/docker
# touch /opt/docker/Dockerfile
# cat <<EOT>> /opt/docker/Dockerfile
# # pull tomcat image from docker hub
# FROM tomcat
# FROM openjdk:8-jre-slim
# #copy war file on the container
# COPY spring-petclinic-2.4.2.war app/
# WORKDIR app/
# RUN pwd
# RUN ls -al
# ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
# EOT
# touch /opt/docker/docker-image.yml
# cat <<EOT>> /opt/docker/docker-image.yml
# ---
#  - hosts: localhost
#   #root access to user
#    become: true
#    tasks:
#    - name: login to dockerhub
#      command: docker login -u cloudhight -p CloudHight_Admin123@
#    - name: Create docker image from Pet Adoption war file
#      command: docker build -t pet-adoption-image .
#      args:
#        chdir: /opt/docker
#    - name: Add tag to image
#      command: docker tag pet-adoption-image cloudhight/pet-adoption-image
#    - name: Push image to docker hub
#      command: docker push cloudhight/pet-adoption-image
#    - name: Remove docker image from Ansible node
#      command: docker rmi pet-adoption-image cloudhight/pet-adoption-image
#      ignore_errors: yes
# EOT
# touch /opt/docker/dockerstage-container.yml
# cat <<EOT>> /opt/docker/dockerstage-container.yml
# ---
#  - hosts: docker_stage
#    become: true
#    tasks:
#    - name: login to dockerhub
#      command: docker login -u cloudhight -p CloudHight_Admin123@
#    - name: Stop any container running
#      command: docker stop pet-adoption-container
#      ignore_errors: yes
#    - name: Remove stopped container
#      command: docker rm pet-adoption-container
#      ignore_errors: yes
#    - name: Remove docker image
#      command: docker rmi cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Pull docker image from dockerhub
#      command: docker pull cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Create container from pet adoption image
#      command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
#      ignore_errors: yes
# EOT
# touch /opt/docker/dockerprod-container.yml
# cat <<EOT>> /opt/docker/dockerprod-container.yml
# ---
#  - hosts: docker_prod
#    become: true
#    tasks:
#    - name: login to dockerhub
#      command: docker login -u cloudhight -p CloudHight_Admin123@
#    - name: Stop any container running
#      command: docker stop pet-adoption-container
#      ignore_errors: yes
#    - name: Remove stopped container
#      command: docker rm pet-adoption-container
#      ignore_errors: yes
#    - name: Remove docker image
#      command: docker rmi cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Pull docker image from dockerhub
#      command: docker pull cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Create container from pet adoption image
#      command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
#      ignore_errors: yes
# EOT
# cat << EOT > /opt/docker/newrelic.yml
# ---
#  - hosts: docker
#    become: true
#    tasks:
#    - name: install newrelic agent
#      command: docker run \
#                      -d \
#                      --name newrelic-infra \
#                      --network=host \
#                      --cap-add=SYS_PTRACE \
#                      --privileged \
#                      --pid=host \
#                      -v "/:/host:ro" \
#                      -v "/var/run/docker.sock:/var/run/docker.sock" \
#                      -e NRIA_LICENSE_KEY=eu01xxbc4708e1fdb63633cc49bb88b3ce5cNRAL \
#                      newrelic/infrastructure:latest
# EOT
# sudo hostnamectl set-hostname Ansible
# EOF
# }






# locals {
#   ansible_user_data = <<-EOF
# #!/bin/bash
# sudo yum update -y
# sudo yum upgrade -y
# sudo yum install python3.8 -y
# sudo alternatives --set python /usr/bin/python3.8
# sudo yum -y install python3-pip
# sudo yum install ansible -y
# pip3 install ansible --user
# sudo chown ec2-user:ec2-user /etc/ansible
# #NEW RELIC SETUP
# echo "license_key: eu01xx7f52e170948bda373b5b56692bc00aNRAL" | sudo tee -a /etc/newrelic-infra.yml
# sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
# sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
# sudo yum install newrelic-infra -y
# echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/ssh_config.d/10-insecure-rsa-keysig.conf
# sudo service sshd reload
# sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
# echo "${var.prv_key}" >> /home/ec2-user/.ssh/anskey_rsa
# sudo chmod 400 anskey_rsa
# sudo chmod -R 700 .ssh/
# sudo chown -R ec2-user:ec2-user .ssh/
# sudo yum install -y yum-utils
# #DOCKER HUB CONFIGURATION
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum install docker-ce -y
# sudo systemctl start docker
# sudo usermod -aG docker ec2-user
# #CHANGE OWNERSHIP OF DIRECTORY TO EC2-USER
# cd /etc
# sudo chown ec2-user:ec2-user hosts
# cat <<EOT>> /etc/ansible/hosts
# localhost ansible_connection=local
# [dockerstage_host]
# ${var.dockerstageIp} ansible_ssh_private_key_file=/home/ec2-user/.ssh/anskey_rsa
# [dockerprod_host]
# ${var.dockerprodIp}  ansible_ssh_private_key_file=/home/ec2-user/.ssh/anskey_rsa
# EOT
# sudo mkdir /opt/docker
# sudo chown -R ec2-user:ec2-user /opt/docker
# sudo chmod -R 700 /opt/docker
# touch /opt/docker/Dockerfile
# cat <<EOT>> /opt/docker/Dockerfile
# # pull tomcat image from docker hub
# FROM tomcat
# FROM openjdk:8-jre-slim
# #copy war file on the container
# COPY spring-petclinic-2.4.2.war app/
# WORKDIR app/
# RUN pwd
# RUN ls -al
# ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
# EOT
# 






# locals {
#   ansible_user_data = <<-EOF
# #!/bin/bash
# sudo yum update -y
# sudo yum upgrade -y
# wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# sudo yum install epel-release-latest-7.noarch.rpm -y
# sudo yum update -y
# sudo yum install python python-devel python-pip ansible -y
# sudo chown ec2-user:ec2-user /etc/ansible
# #NEW RELIC SETUP
# echo "license_key: eu01xx7f52e170948bda373b5b56692bc00aNRAL" | sudo tee -a /etc/newrelic-infra.yml
# sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
# sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
# sudo yum install newrelic-infra -y
# echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/ssh_config.d/10-insecure-rsa-keysig.conf
# sudo service sshd reload
# sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
# echo "${var.prv_key}" >> /home/ec2-user/.ssh/anskey_rsa
# sudo chmod 400 anskey_rsa
# sudo chmod -R 700 .ssh/
# sudo chown -R ec2-user:ec2-user .ssh/
# sudo yum install -y yum-utils
# #DOCKER HUB CONFIGURATION
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum install docker-ce -y
# sudo systemctl start docker
# sudo usermod -aG docker ec2-user
# #CHANGE OWNERSHIP OF DIRECTORY TO EC2-USER
# cd /etc
# sudo chown ec2-user:ec2-user hosts
# cat <<EOT>> /etc/ansible/hosts
# localhost ansible_connection=local
# [dockerstage_host]
# ${var.dockerstageIp} ansible_ssh_private_key_file=/home/ec2-user/.ssh/anskey_rsa
# [dockerprod_host]
# ${var.dockerprodIp}  ansible_ssh_private_key_file=/home/ec2-user/.ssh/anskey_rsa
# EOT
# sudo mkdir /opt/docker
# sudo chown -R ec2-user:ec2-user /opt/docker
# sudo chmod -R 700 /opt/docker
# touch /opt/docker/Dockerfile
# cat <<EOT>> /opt/docker/Dockerfile
# # pull tomcat image from docker hub
# FROM tomcat
# FROM openjdk:8-jre-slim
# #copy war file on the container
# COPY spring-petclinic-2.4.2.war app/
# WORKDIR app/
# RUN pwd
# RUN ls -al
# ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
# EOT
# touch /opt/docker/docker-image.yml
# cat <<EOT>> /opt/docker/docker-image.yml
# ---
#  - hosts: localhost
#   #root access to user
#    become: true
#    tasks:
#    - name: login to dockerhub
#      command: docker login -u cloudhight -p CloudHight_Admin123@
#    - name: Create docker image from Pet Adoption war file
#      command: docker build -t pet-adoption-image .
#      args:
#        chdir: /opt/docker
#    - name: Add tag to image
#      command: docker tag pet-adoption-image cloudhight/pet-adoption-image
#    - name: Push image to docker hub
#      command: docker push cloudhight/pet-adoption-image
#    - name: Remove docker image from Ansible node
#      command: docker rmi pet-adoption-image cloudhight/pet-adoption-image
#      ignore_errors: yes
# EOT
# touch /opt/docker/dockerstage-container.yml
# cat <<EOT>> /opt/docker/dockerprod-container.yml
# ---
#  - hosts: docker_host
#    become: true
#    tasks:
#    - name: login to dockerhub
#      command: docker login -u cloudhight -p CloudHight_Admin123@
#    - name: Stop any container running
#      command: docker stop pet-adoption-container
#      ignore_errors: yes
#    - name: Remove stopped container
#      command: docker rm pet-adoption-container
#      ignore_errors: yes
#    - name: Remove docker image
#      command: docker rmi cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Pull docker image from dockerhub
#      command: docker pull cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Create container from pet adoption image
#      command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
#      ignore_errors: yes
# EOT
# touch /opt/docker/dockerprod-container.yml
# cat <<EOT>> /opt/docker/docker-container.yml
# ---
#  - hosts: docker_host
#    become: true
#    tasks:
#    - name: login to dockerhub
#      command: docker login -u cloudhight -p CloudHight_Admin123@
#    - name: Stop any container running
#      command: docker stop pet-adoption-container
#      ignore_errors: yes
#    - name: Remove stopped container
#      command: docker rm pet-adoption-container
#      ignore_errors: yes
#    - name: Remove docker image
#      command: docker rmi cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Pull docker image from dockerhub
#      command: docker pull cloudhight/pet-adoption-image
#      ignore_errors: yes
#    - name: Create container from pet adoption image
#      command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
#      ignore_errors: yes
# EOT
# cat << EOT > /opt/docker/newrelic.yml
# ---
#  - hosts: docker
#    become: true
#    tasks:
#    - name: install newrelic agent
#      command: docker run \
#                      -d \
#                      --name newrelic-infra \
#                      --network=host \
#                      --cap-add=SYS_PTRACE \
#                      --privileged \
#                      --pid=host \
#                      -v "/:/host:ro" \
#                      -v "/var/run/docker.sock:/var/run/docker.sock" \
#                      -e NRIA_LICENSE_KEY=eu01xx7f52e170948bda373b5b56692bc00aNRAL \
#                      newrelic/infrastructure:latest
# EOT
# sudo hostnamectl set-hostname Ansible
# EOF
# }
