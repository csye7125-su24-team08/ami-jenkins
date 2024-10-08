multibranchPipelineJob('Infra Jenkins') {
  branchSources {
    github {
      id('team08-infra-jenkins')
      scanCredentialsId('GITHUB_CREDENTIALS')
      repoOwner('csye7125-su24-team08')
      repository('infra-jenkins')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
