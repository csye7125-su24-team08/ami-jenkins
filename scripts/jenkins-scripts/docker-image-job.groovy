import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

// Define the job name and script
def jobName = 'Static-site-docker-image-job'
def jobScript = '''
pipeline {
  triggers{
    githubWebhook()
  }
  environment {
    registry = "dongrep/static-site"
    registryCredential = 'docker-credentials'
    gitCredential = 'github-credentials'
    DOCKER_CERT_PATH = credentials('docker-credentials')
  }
  agent any
  stages {
    stage('Cloning our Git') {
      steps {
        git credentialsId: gitCredential, url: 'https://github.com/cyse7125-su24-team08/static-site.git', branch: 'main'
      
        echo "Fetch successfull"
      }
    }
    stage('Checking if docker available') {
      steps{
        script {
            echo "Checking docker version"
            sh "docker --version"
        }
      }
    }
    stage('Building our image') {
      steps{
        script {
            echo "Building Image with BUILD_NUMBER - $BUILD_NUMBER"
            dockerImage = docker.build registry + ":$BUILD_NUMBER"
        }
      }
    }
    stage('Deploy our image') {
      steps{
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Cleaning up') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
  }
}
'''

// Get Jenkins instance
def instance = Jenkins.getInstance()

// Create a new pipeline job
def job = instance.createProject(WorkflowJob, jobName)
job.definition = new CpsFlowDefinition(jobScript, true)

// Save the job
job.save()

println "Job '${jobName}' created successfully!"
