multibranchPipelineJob('helm-webapp') {
  branchSources {
    github {
      id('team08-helm-webapp-cve-processor')
      scanCredentialsId('GITHUB_CREDENTIALS')
      repoOwner('cyse7125-su24-team08')
      repository('helm-webapp-cve-processor')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(5)
      daysToKeep(1)
    }
  }
}
