#!/bin/bash

echo "Installing Jenkins"
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
  docker-pipeline
  docker
)

# Install the recommended plugins
echo "Installing recommended plugins"
for plugin in "${plugins[@]}"; do
  echo "Installing plugin: $plugin"
  java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" install-plugin "$plugin"
done

echo "Install Docker"
sudo apt-get update -y
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install docker-ce -y
sudo usermod -aG docker jenkins

echo "Restarting Jenkins to apply plugin changes"
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth $JENKINS_USER:$JENKINS_PASSWORD safe-restart
