pipeline {
  environment {
    registry = "01141354474/online-challenge"
    registryCredential = 'dockerhub'
    dockerImage = ''
    failureReportSubject = "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - FAILURE!"
    adminEmails = "medokingdom7@gmail.com"
    applicationReleaseVersion = "latest-1.2.0"
    loadBalanceYML = "load-balance.yml"
    serviceDeploymentYML = "service-deployment.yml"
    kubeConfigKey = "kubeConfigKey"
  }
  agent any
  stages {
    stage('Building image') {
      steps {
        script {
          catchError {
            dockerImage = docker.build registry + ":" + applicationReleaseVersion
          }
        }
      }
      post {
        success {
          echo "Built successfully"
        }
        failure {
          unstable("There is a failure in build stage.\nCheck Admin's Email now!")
          emailext (subject: failureReportSubject, to: adminEmails, replyTo: adminEmails,
                        body: "There is a failure in build stage.\nCheck the logs now!", attachLog: true)
        }
      }
    }
    stage('Pushing Image To Dockerhub') {
      steps {
        script {
          try {
            docker.withRegistry('', registryCredential) {
              dockerImage.push()
            }
          } catch(Exception e) {
            unstable("Warning: ${e.message}")
          }
        }
      }
    }
    stage('Remove docker image after push to dockerhub') {
      steps {
        script {
          try {
            sh "docker rmi $registry:" + applicationReleaseVersion
          } catch(Exception e) {
            unstable("Warning: ${e.message}")
          }
        }
      }
    }
    stage("Deploying To Kubernetes Server") {
      steps {
        script {
          try {
            kubernetesDeploy(configs: "${loadBalanceYML}", kubeconfigId: kubeConfigKey)
            kubernetesDeploy(configs: "${serviceDeploymentYML}", kubeconfigId: kubeConfigKey)
          } catch(Exception e) {
            unstable("Warning: ${e.message}")
          }
        }
      }
    }
  }
}