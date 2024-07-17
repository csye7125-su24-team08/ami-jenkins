multibranchPipelineJob('Helm EKS Autoscaler') {
  branchSources {
    github {
      id('team08-helm-eks-autoscaler')
      scanCredentialsId('GITHUB_CREDENTIALS')
      repoOwner('csye7125-su24-team08')
      repository('helm-eks-autoscaler')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
