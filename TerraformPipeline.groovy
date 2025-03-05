def TerraformPipeline() {
    pipeline {
        agent { label 'terraform-agent' }
        
        tools {
            terraform 'terraform-1.4.5'
            nodejs 'nodejs-12.6'
        }
        
        stages {
            stage('Terraform Init') {
                steps {
                    script {
                        sh 'terraform init'
                    }
                }
            }
            
            stage('Terraform Plan') {
                steps {
                    script {
                        sh 'terraform plan'
                    }
                }
            }
            
            stage('Terraform Apply') {
                steps {
                    script {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }
}
