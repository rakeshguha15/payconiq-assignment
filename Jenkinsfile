//This pipeline assumes that Pre-requisites are configured in Jenkins Environment
//If unsure please check pre-requisites sections WORKLOG.md file
pipeline {
  agent { label 'linux'}
  options {
    skipDefaultCheckout(true)
  }
  parameters {
        choice (name: 'AWS_REGION',choices: ['eu-central-1','us-west-1', 'us-west-2'],description: 'Choose Region Where you want to Deploy: ')
        choice (name: 'ACTION',choices: ['Deploy Stack', 'Delete Stack'],description: 'Choose What do you want to do: ')
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
        if ("${env.ACTION}" == 'Deploy Stack') {
          withAWS(credntials: 'EKSCred') {
            if (fileExists("./terraform-eks/${env.AWS_REGION}.tfvars")) {
              sh 'cd terraform-eks && ./terraform init && ./terraform apply -auto-approve -no-color -var-file ${env.AWS_REGION}.tfvars'
            }
            else{
              echo "ERROR: NO tfvars \nPlease Check you have the tfvars file configured for the region ${env.AWS_REGION}!"
              currentBuild.result = "FAILURE"
            }
          }
        }
        if ("${env.ACTION}" == 'Delete Stack') {
          withAWS(credntials: 'EKSCred') {
            if (fileExists("./terraform-eks/${env.AWS_REGION}.tfvars")) {
              sh 'cd terraform-eks && ./terraform init && ./terraform destroy -auto-approve -no-color -var-file ${env.AWS_REGION}.tfvars'
            }
            else{
              echo "ERROR: NO tfvars \nPlease Check you have the tfvars file configured for the region ${env.AWS_REGION}!"
              currentBuild.result = "FAILURE"
            }
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