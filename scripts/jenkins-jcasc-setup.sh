#!/bin/bash

cho "Installing Jenkins"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo apt-get install jenkins -y

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

java -version

echo "Starting Jenkins"
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Setup Jenkins CLI"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar

jenkins-plugin-cli --plugin-file ~/jenkins-scripts/plugins.txt

export JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
export CASC_JENKINS_CONFIG="/var/jenkins_home/casc.yaml"

sudo cp ~/jenkins/casc.yaml /var/jenkins_home/casc.yaml

echo "Restarting Jenkins"
sudo systemctl restart jenkins
