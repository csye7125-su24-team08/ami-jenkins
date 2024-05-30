import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

// Define the job name and script
def jobName = 'simple-pipeline-job'
def jobScript = '''
pipeline {
    agent any
    stages {
        stage('Hello') {
            steps {
                echo 'Hello, World!'
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
