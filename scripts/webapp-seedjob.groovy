multibranchPipelineJob('webapp-cve-processor') {
  branchSources {
    github {
      id('team08-webapp-cve-processor')
      scanCredentialsId('GITHUB_CREDENTIALS')
      repoOwner('csye7125-su24-team08')
      repository('webapp-cve-processor')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(5)
      daysToKeep(1)
    }
  }
}
