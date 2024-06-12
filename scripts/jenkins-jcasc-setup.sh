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
  nodejs
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
sudo mv ~/*.groovy /var/lib/jenkins/
sudo chown jenkins:jenkins /var/lib/jenkins/*

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

echo "**************************************************************************"
echo "*                                                                        *"
echo "*                                                                        *"
echo "*                           Installing Nodejs                            *"
echo "*                                                                        *"
echo "*                                                                        *"
echo "**************************************************************************"

# Download and import the Nodesource GPG key
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo \
  gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Create a deb repository
NODE_MAJOR=22
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo \
  tee /etc/apt/sources.list.d/nodesource.list

# Run update and install
sudo apt-get update && sudo apt-get install nodejs -y

sleep 3

# Check Node version:
echo "Node $(node --version)"

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

echo "**************************************************************************"
echo "*                                                                        *"
echo "*                                                                        *"
echo "*                           Installing Helm                              *"
echo "*                                                                        *"
echo "*                                                                        *"
echo "**************************************************************************"

sudo apt-get update
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
sudo apt-get install apt-transport-https -y
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" |
  sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update && sudo apt-get install helm

# Check Helm version
echo "Helm $(helm version)"


echo "**************************************************************************"
echo "*                                                                        *"
echo "*                                                                        *"
echo "*                           Installing Kubectl                           *"
echo "*                                                                        *"
echo "*                                                                        *"
echo "**************************************************************************"

sudo apt-get update
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key |
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' |
  sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install kubectl -y

# Check Kubectl version
echo "Kubectl $(kubectl version --client)"
