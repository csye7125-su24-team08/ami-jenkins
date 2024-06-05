#!/bin/bash

export JENKINS_URL=http://localhost:8080
export JENKINS_USER=admin
export JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Create a new Jenkins job
echo "Creating a new users - admin, piyush, and anuraag"
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" groovy = <./jenkins-scripts/new_user.groovy
