pipeline 
{ 
  agent any

  options {
        disableConcurrentBuilds()
  }


  environment {
    amiNameTag = ""
    amiNameTagValue = "";
    thisTestNameVar = "";
    thisTestValue = "blue_green_deployment";
    ProjectName = "petclinic-spring";
    fileProperties = "file.properties"
    old_environment = "";
  }

  stages {

   stage('Get Blue-Green Deployment Repo')
   {
      steps {
        echo "Getting Exploratory Testing Repo"
        git(
        url:'git@github.com:bglogowski/petclinic-blue-green.git',
        credentialsId: '993c4ceb-d3c7-4a1d-9788-3d753a462b4a',
        branch: "main"
        )
     }

   }


   stage('Read Properties File') {
      steps {
        script {
           slackSend channel: '#jenkins', message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} stage: Read Properties File"

           copyArtifacts(projectName: "${ProjectName}");
           props = readProperties file:"${fileProperties}";

           this_group = props.Group;
           this_version = props.Version;
           this_artifact = props.ArtifactId;
           this_full_build_id = props.FullBuildId;
           this_jenkins_build_id = props.JenkinsBuildId;
        }


        sh "echo Finished setting this_group = $this_group"
        sh "echo Finished setting this_version = $this_version"
        sh "echo Finished setting this_artifact = $this_artifact"
        sh "echo Finished setting this_full_build_id = $this_full_build_id"
        sh "echo Finished setting this_jenkins_build_id = $this_jenkins_build_id"

      }
    }


      stage('SELECT DEPLOYMENT ENVIRONMENT - INPUT REQUIRED')
      {
        steps
        {
           echo "Starting --- deployment" 
           sh 'pwd'
           script {
              slackSend channel: '#jenkins', message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} stage: SELECT DEPLOYMENT ENVIRONMENT - INPUT REQUIRED"
              env.DEPLOY_TO = input message: 'Please select environment location to deploy', parameters: [choice(name: 'Environments Available', choices: 'BLUE\nGREEN', description: 'WARNING: Before deploying release, the selected environment will be replaced with the new deployment' )]
           }
           echo "Selected Environment to Deploy:  "
           echo "${env.DEPLOY_TO}"
        }
      }



      stage('Deploying VPC')
      {
        steps
        {
           echo "Starting VPC Deployment --- terraform deploy and start"

           sh 'pwd'
           dir('./production')
           {
              script {
                 slackSend channel: '#jenkins', message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} stage: Deploying VPC"
                 sh 'pwd'

                 echo "update terraform variables "

                 amiNameTagValue = "$this_artifact" + "-" + "$this_jenkins_build_id";
                 amiNameTag = "build_id=\"" + "$amiNameTagValue" + "\"";
                 thisTestNameVar = "test-name=\"" + "$thisTestValue" + "\"";

                 def readContent = readFile 'terraform.tfvars'
                 writeFile file: 'terraform.tfvars', text: readContent+"\n$amiNameTag"+"\n$thisTestNameVar"

                 sh 'pwd'
                 sh 'ls -l'
                 sh '/usr/bin/terraform init -input=false -no-color'
                 sh '/usr/bin/terraform plan -no-color'
                 sh '/usr/bin/terraform apply -auto-approve -no-color'
              
              }
           }


        }
      }


      stage('Deploying Environment')
      {
        steps
        {
           echo "Starting --- terraform deploy and start"

           sh 'pwd'
           dir("${env.DEPLOY_TO}")
           {
              script {
                 slackSend channel: '#jenkins', message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} stage: Deploying Environment"
                 sh 'pwd'

                 echo "update terraform variables "

                 amiNameTagValue = "$this_artifact" + "-" + "$this_jenkins_build_id";
                 amiNameTag = "build_id=\"" + "$amiNameTagValue" + "\"";
                 thisTestNameVar = "test-name=\"" + "$thisTestValue" + "\"";

                 def readContent = readFile 'terraform.tfvars'
                 writeFile file: 'terraform.tfvars', text: readContent+"\n$amiNameTag"+"\n$thisTestNameVar"

                 sh 'pwd'
                 sh 'ls -l'
                 sh '/usr/bin/terraform init -input=false -no-color'
                 sh '/usr/bin/terraform plan -no-color'
                 try {
                    sh '/usr/bin/terraform apply -auto-approve -no-color'
                 } catch (err) {
                    sh '/usr/bin/terraform apply -auto-approve -no-color'
                 }
              
              }
           }


        }
      }

      stage('Destroy Environment - INPUT REQUIRED')
      {
        steps
        {
           echo "Starting --- terraform deploy and start"

           sh 'pwd'
           script {
              slackSend channel: '#jenkins', message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} stage: Destroy Environment - INPUT REQUIRED"
          
              if (env.DEPLOY_TO == "GREEN") {  
                 old_environment = "BLUE"
                 echo "setting old_environment to: $old_environment"
              } else {
                 old_environment = "GREEN"
                 echo "setting old_environment to: $old_environment"
              }

              this_input_message = "Do you want to destroy the $old_environment environment?"
              this_warning_message = "WARNING: The $old_environment environment will be destroy"

              env.Destroy_Environment = input message: "$this_input_message", parameters: [choice(name: 'Please select', choices: 'NO\nYES', description: "$this_warning_message" )]

              echo "Destroy Environment:  "
              echo "${env.Destroy_Environment}"

              if (env.Destroy_Environment == "YES") {  
                 dir("$old_environment")
                 {
                    sh 'pwd'

                   // Terraform fails if it is unable to retrieve the amiName from the data, even though it does not need it,
                   // because this is a destroy call. 
                   def readContent = readFile 'terraform.tfvars'
                   writeFile file: 'terraform.tfvars', text: readContent+"\n$amiNameTag"+"\n$thisTestNameVar"

                   echo "Test completed, destroying environment"
                   sh '/usr/bin/terraform destroy -auto-approve -no-color'
                 }
              } 
              echo "Done with stage" 
           }
        }
      }


  }

 }
