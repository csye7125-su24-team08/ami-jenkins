export JENKINS_URL=http://localhost:8080
export JENKINS_USER=admin
export JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Set env variable for github pat"
export GH_ACCESS_TOKEN=$(head -n 1 tokens.txt)


echo "Setup Github credentials"
while ! java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth $JENKINS_USER:$JENKINS_PASSWORD groovy = < ~/jenkins-scripts/gh-creds.groovy $GH_ACCESS_TOKEN; do
  echo "Command failed. Retrying in 5 seconds..."
  sleep 5
done


echo "Set env variable for docker"
export DOCKER_ACCESS_TOKEN=$(head -n 2 tokens.txt | sed -n 2p)

echo "Setup Docker credentials"
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth $JENKINS_USER:$JENKINS_PASSWORD groovy = < ~/jenkins-scripts/docker-creds.groovy $DOCKER_ACCESS_TOKEN

echo "Setup Docker image builder job"
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth $JENKINS_USER:$JENKINS_PASSWORD groovy = < ~/jenkins-scripts/docker-image-job.groovy

rm tokens.txt
