pipelineJob('seed-job-static-site') {
  description('My Pipeline Job Description')
  definition {
      cpsScm {
        scriptPath('Jenkinsfile') // Reference the Jenkinsfile in your SCM
        scm {
          git {
            remote {
              url('https://github.com/cyse7125-su24-team08/static-site.git')
              credentials('GITHUB_CREDENTIALS') // Specify your GitHub credentials ID
            }
            branch('main') // Specify the branch you want to build
          }
        }
      }
    }
  triggers {
      githubPush() // Trigger the job on a GitHub push event
  }
}
