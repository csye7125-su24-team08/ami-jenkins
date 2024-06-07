#!/bin/bash

echo "-----------------------------Installing Jenkins-----------------------------"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo apt-get install jenkins -y

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

java -version

# Install Jenkins plugin manager tool:
echo "Installing Jenkins plugin manager tool"
wget --quiet \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar

# Install plugins with jenkins-plugin-manager tool:
echo "Installing Jenkins plugins"
sudo java -jar ./jenkins-plugin-manager-2.13.0.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file ~/jenkins-scripts/plugins.txt

sudo chown jenkins:jenkins /var/lib/jenkins/plugins/*

# Replace placeholders in the casc.yaml file
echo "Replacing placeholders in the casc.yaml file"
sudo sed -i "s/\${GH_ACCESS_TOKEN}/$GH_ACCESS_TOKEN/g" ~/jenkins-scripts/casc.yaml
sed -i "s/\${DOCKER_ACCESS_TOKEN}/$DOCKER_ACCESS_TOKEN/g" ~/jenkins-scripts/casc.yaml

echo "Copying JCasC configuration"
sudo cp ~/jenkins-scripts/casc.yaml /var/lib/jenkins/casc.yaml
sudo chown jenkins:jenkins /var/lib/jenkins/casc.yaml

# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/casc.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

echo "Starting Jenkins"
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins

echo "Jenkins setup completed"

# Add Docker's official GPG key:
echo "-----------------------------Installing Docker-----------------------------"
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker:
sudo apt-get update && sudo apt-get install docker-ce -y

# Provide relevant permissions
sudo chmod 666 /var/run/docker.sock
sudo usermod -a -G docker jenkins

# Check Docker version
echo "Docker $(docker --version)"
