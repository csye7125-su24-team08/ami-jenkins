#!/bin/bash

echo "**************************************************************************"
echo "*                                                                        *"
echo "*                                                                        *"
echo "*                           Installing Jenkins                           *"
echo "*                                                                        *"
echo "*                                                                        *"
echo "**************************************************************************"

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo apt-get install jenkins -y

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

java -version

echo "Starting Jenkins"
sudo systemctl start jenkins

echo "Setup Jenkins CLI"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar

# Wait for Jenkins to start (replace localhost with your Jenkins hostname if necessary)
echo "Waiting for Jenkins to start"
while ! nc -z localhost 8080; do
  sleep 1
done

export JENKINS_URL=http://localhost:8080
export JENKINS_USER=admin
export JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Install recommended plugins
plugins=(
  cloudbees-folder
  antisamy-markup-formatter
  build-timeout
  credentials-binding
  timestamper
  ws-cleanup
  ant
  gradle
  workflow-aggregator
  github-branch-source
  pipeline-github-lib
  pipeline-stage-view
  git
  github
  github-api
  ssh-slaves
  matrix-auth
  pam-auth
  ldap
  email-ext
  mailer
  metrics
  pipeline-graph-view
  docker-commons
  configuration-as-code
  job-dsl
)

# Install the recommended plugins
echo "Installing recommended plugins"
for plugin in "${plugins[@]}"; do
  echo "Installing plugin: $plugin"
  java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" install-plugin "$plugin"
done

export GH_ACCESS_TOKEN=$(head -n 1 tokens.txt)
export DOCKER_ACCESS_TOKEN=$(tail -n 1 tokens.txt)

# Replace placeholders in the casc.yaml file
echo "Replacing placeholders in the casc.yaml file"
sudo sed -i "s/\${GH_ACCESS_TOKEN}/$GH_ACCESS_TOKEN/g" ~/casc.yaml
sudo sed -i "s/\${DOCKER_ACCESS_TOKEN}/$DOCKER_ACCESS_TOKEN/g" ~/casc.yaml

echo "Copying JCasC configuration"
sudo mv ~/casc.yaml /var/lib/jenkins/casc.yaml
sudo chown jenkins:jenkins /var/lib/jenkins/casc.yaml

echo "Copying Jenkins jobs"
sudo mv ~/seedjob.groovy /var/lib/jenkins/seedjob.groovy
sudo chown jenkins:jenkins /var/lib/jenkins/seedjob.groovy

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
echo "**************************************************************************"
echo "*                                                                        *"
echo "*                                                                        *"
echo "*                           Installing Docker                            *"
echo "*                                                                        *"
echo "*                                                                        *"
echo "**************************************************************************"
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
