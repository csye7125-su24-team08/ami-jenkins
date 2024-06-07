#!/bin/bash

echo "Installing Jenkins"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo apt-get install jenkins -y

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

java -version

echo "Disabling Jenkins setup wizard"
sudo tee /etc/default/jenkins >/dev/null <<EOL
JAVA_ARGS="-Djenkins.install.runSetupWizard=false"
EOL

echo "Starting Jenkins"
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Setup Jenkins CLI"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar

export JENKINS_URL=http://localhost:8080
export JENKINS_USER=admin
export JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

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
  job-dsl
  configuration-as-code
)

echo "Installing recommended plugins"
for plugin in "${plugins[@]}"; do
  echo "Installing plugin: $plugin"
  while ! java -jar ~/jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" install-plugin "$plugin"; do
    echo "Command failed. Retrying in 5 seconds..."
    sleep 5
  done
done

echo "Stopping Jenkins to apply configuration"
sudo systemctl stop jenkins

echo "Copying JCasC configuration"
sudo mkdir -p /var/jenkins_home
sudo cp ~/jenkins-scripts/casc.yaml /var/jenkins_home/casc.yaml
export CASC_JENKINS_CONFIG="/var/jenkins_home/casc.yaml"
sudo chown -R jenkins:jenkins /var/jenkins_home

echo "Setting JCasC environment variable"
echo 'CASC_JENKINS_CONFIG="/var/jenkins_home/casc.yaml"' | sudo tee -a /etc/default/jenkins >/dev/null

echo "Restarting Jenkins to apply configuration"
sudo systemctl start jenkins

echo "Jenkins setup completed"
