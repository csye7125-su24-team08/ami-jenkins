#!/bin/bash

export JENKINS_URL=http://localhost:8080
export JENKINS_USER=admin
export JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Sleep till Jenkins is up"
while ! nc -z localhost 8080; do
  sleep 30
done

# Create a new Jenkins job
echo "Creating a new users - admin, piyush, and anuraag - if fails then try again"

while ! java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth $JENKINS_USER:$JENKINS_PASSWORD groovy = < ~/jenkins-scripts/create-user.groovy; do
  echo "Command failed. Retrying in 5 seconds..."
  sleep 5
done
