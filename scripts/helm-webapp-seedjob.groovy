multibranchPipelineJob('Helm Charts Webapp') {
  branchSources {
    github {
      id('team08-helm-webapp-cve-processor')
      scanCredentialsId('GITHUB_CREDENTIALS')
      repoOwner('csye7125-su24-team08')
      repository('helm-webapp-cve-processor')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
