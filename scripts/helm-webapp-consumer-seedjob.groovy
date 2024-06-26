multibranchPipelineJob('Helm Webapp Consumer') {
  branchSources {
    github {
      id('team08-helm-webapp-cve-consumer')
      scanCredentialsId('GITHUB_CREDENTIALS')
      repoOwner('csye7125-su24-team08')
      repository('helm-webapp-cve-consumer')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
