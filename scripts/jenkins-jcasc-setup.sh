#!/bin/bash

echo "Installing Jenkins"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo apt-get install jenkins -y

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

java -version

echo "Setup Jenkins CLI"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar

echo "Installing necessary plugins"
jenkins-plugin-cli --plugins configuration-as-code git github github-api job-dsl github-branch-source

echo "Disabling Jenkins setup wizard"
export JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
sudo systemctl daemon-reload
sudo systemctl enable jenkins

echo "Copying JCasC configuration"
sudo mkdir -p /var/jenkins_home
sudo cp ~/jenkins/casc.yaml /var/jenkins_home/casc.yaml
export CASC_JENKINS_CONFIG="/var/jenkins_home/casc.yaml"

echo "Starting Jenkins"
sudo systemctl start jenkins

echo "Restarting Jenkins to apply configuration"
sudo systemctl restart jenkins
