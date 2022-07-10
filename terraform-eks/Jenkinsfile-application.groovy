//This pipeline assumes that Pre-requisites are configured in Jenkins Environment
//If unsure please check pre-requisites sections WORKLOG.md file
pipeline {
  agent { label 'linux'}
  options {
    skipDefaultCheckout(true)
  }
  parameters {
        choice (name: 'AWS_REGION',choices: ['eu-central-1','us-west-1', 'us-west-2'],description: 'Choose Region Where you want to modify application: ')
        choice (name: 'APP_NAME',choices: ['ghost-blog-stateless', 'node-red-stateful'],description: 'Choose which application you want to modify: ')
        choice (name: 'ACTION',choices: ['Install Application','Update Application', 'Delete Application'],description: 'Choose What do you want to do: ')
        string (name: 'NEW_TAG', defaultValue: "Skip", description: 'Type Docker Image Tag for application update', trim: true)
        string (name: 'CLUSTER_NAME', description: 'Type Cluster Name where you want to update application stack', trim: true)
    }
  stages{
    stage('clean workspace') {
      steps {
        cleanWs()
      }
    }
    stage('checkout') {
      steps {
        checkout scm
      }
    }
    stage('Action') {
      steps {
        if ("${env.ACTION}" == 'Install Application') {
          withAWS(credntials: 'EKSCred') {
            sh "aws eks --region ${env.AWS_REGION} update-kubeconfig --name ${env.CLUSTER_NAME}"
            if ("${env.ACTION}".toLowerCase() != "skip") {
              sh "helm install ${env.APP_NAME} ./${env.APP_NAME}"
            } 
          }
        }
        if ("${env.ACTION}" == 'Update Application') {
          withAWS(credntials: 'EKSCred') {
            sh "aws eks --region ${env.AWS_REGION} update-kubeconfig --name ${env.CLUSTER_NAME}"
            if ("${env.ACTION}".toLowerCase() != "skip") {
              sh "helm upgrade ${env.APP_NAME} --reuse-values --set image.tag=${env.NEW_TAG}"
            }
            else{
              echo "Please choose a tag to update, you chose the default SKIP value. "
            } 
          }
        }
        if ("${env.ACTION}" == 'Delete Application') {
          withAWS(credntials: 'EKSCred') {
            sh "aws eks --region ${env.AWS_REGION} update-kubeconfig --name ${env.CLUSTER_NAME}"
            sh "helm delete ${env.APP_NAME}"
          }
        }     
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}