//Version 2.1.1
pipeline {
  agent none
  environment {
      configDirPath="Configurations"
      configRepo="https://github.com/Tap-Payments/devstack.git"
      def defaultChannel="#${params.envName}-deployments"
      def slackChannel="${params.envName == 'prod' ? '#deployment-notifications' : params.envName == 'development' ? '#dev-deployments' : defaultChannel}"
      POM_USER = credentials('POM_USER')
      POM_PASSWORD = credentials('POM_PASSWORD')
    }

  stages {
    stage ('Checkout devStack')
    {
      agent { label "${params.envName == 'development' || params.envName == 'sandbox' ? 'Dev' : 'Prod'}" }
      when {
        expression { params.jobType == 'rollback' || params.jobType == 'deployment'}
      }
      steps {
      echo "\u001B[32mInfo : Pulling the source code from devstack \u001B[0m"                        
      checkout([$class: 'GitSCM', branches: [[name: "remotes/origin/${params.ConfigbranchName}"]], 
      doGenerateSubmoduleConfigurations: false, 
      extensions: [[$class: 'RelativeTargetDirectory', 
      relativeTargetDir: "${env.configDirPath}"]], submoduleCfg: [], 
      userRemoteConfigs: [[credentialsId: 'Jenkins-github-connection',url: "${env.configRepo}"]]])
      }   
    }
    stage('Rollback') {
      agent { label "${params.envName == 'development' || params.envName == 'sandbox' ? 'Dev' : 'Prod'}" }
      when {
        expression { params.jobType == 'rollback'}
      }
      steps {
        script{
          def exitStatus = sh(script: 'Configurations/scripts/deployment-scripts/rollback.sh', returnStatus: true)
          if (exitStatus != 0) {
              error "Pipeline is failing as script failed with exit status: $exitStatus"
          }
        }
      }
      post {
        always {
          cleanWs(cleanWhenNotBuilt: true, deleteDirs: true, disableDeferredWipeout: true, notFailBuild: true,
                  patterns: [[pattern: '.gitignore', type: 'INCLUDE']])
        }
        success {
          slackSend channel: env.slackChannel, color: 'good', message: "*Reverted ${params.applicationName}*\nEnvironment : ${params.envName}\nJob : ${currentBuild.fullDisplayName} (<${env.BUILD_URL}|Open>)"
        }
        failure
        {
          slackSend channel: env.slackChannel, color: 'danger', message: "*Revert unsuccessful for ${params.applicationName}*\nEnvironment : ${params.envName}\nJob : ${currentBuild.fullDisplayName} (<${env.BUILD_URL}|Open>)"
        }
      }
    }
    stage('deployment') {
      agent { label "${params.envName == 'development' || params.envName == 'sandbox' ? 'Dev' : 'Prod'}" }
      options {
        skipDefaultCheckout(true)  // make sure source repo is checkout only once
      }
      when {
        expression { jobType == 'deployment' }
      }
      environment {
        commitHash = getVersion()
        author = getCommitter()
      }
      steps {
        script {
            if (params.approvalRequired) { 
                slackSend(channel: env.slackChannel, color: "#8ED5EC", message: "*:hourglass_flowing_sand: Approve deployment for ${params.applicationName}*\nEnvironment : ${params.envName}\nJob : ${currentBuild.fullDisplayName} (<${env.BUILD_URL}|Open>)")  
                def prodcheck = input(id: 'Proceed1', message: 'Promote build?', parameters: [[$class: 'BooleanParameterDefinition', defaultValue: true, description: 'Please confirm to proceed with deployment.', name: 'Confirm']])
                echo "prodcheck: ${prodcheck}"
                if (prodcheck) {
                    slackSend(channel: env.slackChannel, color: "#00A1F1", message: "*:mega: Deployment approved for ${params.applicationName}*\nEnvironment : ${params.envName}\nJob : ${currentBuild.fullDisplayName} (<${env.BUILD_URL}|Open>)")
                }
            }
        def exitStatus = sh(script: 'Configurations/scripts/deployment-scripts/build.sh', returnStatus: true)
        if (exitStatus != 0) {
            error "Pipeline is failing as script failed with exit status: ${exitStatus}"
        }
    }
}
      post {
        always {
          cleanWs(cleanWhenNotBuilt: true, deleteDirs: true, disableDeferredWipeout: true, notFailBuild: true,
                  patterns: [[pattern: '.gitignore', type: 'INCLUDE']])
        }
        success {
          slackSend channel: env.slackChannel, color: 'good', message: ":white_check_mark: *Deployment completed on ${params.applicationName}*\nEnvironment : ${params.envName}\nJob : ${currentBuild.fullDisplayName} (<${env.BUILD_URL}|Open>)\nAuthor : ${env.author} | CommitHash : ${env.commitHash}"
        }
        failure
        {
          slackSend channel: env.slackChannel, color: 'danger', message: ":x: *Deployment unsuccessful for ${params.applicationName}*\nEnvironment : ${params.envName}\nJob : ${currentBuild.fullDisplayName} (<${env.BUILD_URL}|Open>)\nAuthor : ${env.author} | CommitHash : ${env.commitHash}"
        }
        aborted
        {
          slackSend channel: env.slackChannel, color: 'warning', message: ":warning: *Deployment aborted for ${params.applicationName}*\nEnvironment : ${params.envName}\nJob : ${currentBuild.fullDisplayName} (<${env.BUILD_URL}|Open>)\nAuthor : ${env.author} | CommitHash : ${env.commitHash}"
        }
      }
    }
  }
}

def getVersion() {
    def shortCommitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
    return shortCommitHash
}
def getCommitter() {
  def author = sh(returnStdout: true, script: 'git show -s --pretty=%an').trim()
  return author
}
