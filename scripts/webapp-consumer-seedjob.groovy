multibranchPipelineJob('Webapp Cve Consumer') {
  branchSources {
    github {
      id('team08-webapp-cve-consumer')
      scanCredentialsId('GITHUB_CREDENTIALS')
      repoOwner('csye7125-su24-team08')
      repository('webapp-cve-consumer')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
