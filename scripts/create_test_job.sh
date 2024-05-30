#!/bin/bash

export JENKINS_URL=http://localhost:8080
export JENKINS_USER=admin
export JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Create a new Jenkins job
echo "Creating a new Jenkins job"
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" groovy = <./test_job.groovy
