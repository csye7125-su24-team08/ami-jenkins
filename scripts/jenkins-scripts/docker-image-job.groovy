import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

// Define the job name and script
def jobName = 'Static-site-docker-image-job'
def jobScript = '''
pipeline {
  environment {
    DOCKER_CLI_EXPERIMENTAL = 'enabled'
    registry = "dongrep/static-site"
    gitCredential = 'github-credentials'
    DOCKERHUB_CREDENTIALS = credentials('docker-credentials')
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
            // Create a builder instance
            sh "docker buildx create --use"
            
            // Build multi-architecture image
            sh "docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t ${registry}:latest ."
            
            // Push multi-architecture image with registry credentials
            sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u dongrep --password-stdin'
            
            sh "docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t ${registry}:latest --push ."
        }
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
