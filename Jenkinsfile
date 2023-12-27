pipeline {
    agent any
    environment {
        NEW_IMAGE_NAME = "balaknuthi/cicd-java-app"
    }
    tools {
        maven 'MAVEN-3.9.6'
    }
    stages {
        stage('Git Checkout') {
            steps {
                script {
                    try {
                        git credentialsId: 'jenkins-github', url: 'https://github.com/BalaDevopsForYou/java-kubernetes-maven-web-app.git'
                    } catch (Exception gitException) {
                        error "Git checkout failed: ${gitException.message}"
                    }
                }
            }
        }
        stage('Maven Build') {
            steps {
                script {
                    try {
                        sh 'mvn clean package'
                    } catch (Exception mavenException) {
                        error "Maven build failed: ${mavenException.message}"
                    }
                }
            }
        }
        stage('sonar-analysis') {
         environment {
              SONAR_URL = 'http://54.89.254.231:9000'
              PROJECT_KEY='mysonar-cicdproject'
                }
            steps {
              script {
                 try {
                    withCredentials([string(credentialsId: 'JENKINS_SONAR', variable: 'SONAR_CREDENTIALS')]) {
                        withSonarQubeEnv('SONAR') {
                            sh "mvn sonar:sonar -Dsonar.host.url=$SONAR_URL -Dsonar.login=$SONAR_CREDENTIALS -Dsonar.projectKey=$PROJECT_KEY"
                    }
                }
            } catch (Exception sonarException) {
                    echo "SonarQube analysis failed: ${sonarException.message}"
                    currentBuild.result = 'FAILURE'
            }
        }
    }
}
stage('sonar-quality-gate-check') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                withSonarQubeEnv('SONAR') {
                    timeout(time: 2, unit: 'MINUTES') {
                        script {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                error "Pipeline aborted due to quality gate failure: ${qg.status}"
                            }
                        }
                    }
                }
            }
        }
    
        stage('Upload war file to Nexus') {
            steps {
                script {
                    try {
                        
                        nexusArtifactUploader artifacts: [
                            [
                                artifactId: '01-maven-web-app',
                                classifier: '', 
                                file: 'target/01-maven-web-app.war', 
                                type: 'war'
                            ]
                        ], 
                        credentialsId: 'NEXUS_CRED', 
                        groupId: 'in.Bala',
                        nexusUrl: '52.91.200.156:8081/', 
                        nexusVersion: 'nexus3', 
                        protocol: 'http',
                        repository: 'maven-snapshots', 
                        version: '5.0-SNAPSHOT'
                    } catch (Exception mavenException) {
                        error "Artifact uploaded failed: ${mavenException.message}"
                    }
                }
            }
        }

            stage('Build Docker Image') {
        steps {
            script {
                def IMAGE_VERSION = "${NEW_IMAGE_NAME}:${BUILD_NUMBER}"
                try {
                    // Build Docker image
                    sh "docker build -t ${IMAGE_VERSION} . "
                } catch (Exception dockerBuildException) {
                    error "Docker build failed: ${dockerBuildException.message}"
                }
            }
        }
    }

    stage('Trivy Scan') {
    steps {
        script {
            def IMAGE_VERSION = "${NEW_IMAGE_NAME}:${BUILD_NUMBER}"
            def trivyExitCode = sh(script: "trivy image ${IMAGE_VERSION} --severity HIGH,CRITICAL ", returnStatus: true)

            if (trivyExitCode != 0) {
                error "Trivy scan failed with exit code ${trivyExitCode}"
            }
        }
    }
}

    stage('Publish Docker Image') {
        steps {
            script {
                def IMAGE_VERSION = "${NEW_IMAGE_NAME}:${BUILD_NUMBER}"
                withCredentials([string(credentialsId: 'jenkins_docker_cred', variable: 'docker_credentials_for_jenkins')]) {
                    try {
                        // Login to Docker registry
                        sh "echo ${docker_credentials_for_jenkins} | docker login -u balaknuthi --password-stdin"

                        // Push Docker image to registry
                        sh "docker push ${IMAGE_VERSION}"
                    } catch (Exception dockerPushException) {
                        error "Docker push failed: ${dockerPushException.message}"
                    }
                }
            }
        }
    }

        stage('Update Deployment File') {
            environment {
                GIT_REPO_NAME = "java-kubernetes-maven-web-app"
                GIT_USER_NAME = "BalaDevopsForYou"
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'NEW_GITHUB_TOKEN', variable: 'NEW_GITHUB_TOKEN_VR')]) {
                        try {
                            sh '''
                                git config user.email "balaknuthi999@gmail.com"
                                git config user.name "BalaDevopsForYou"
                                IMAGE_VERSION=${NEW_IMAGE_NAME}:${BUILD_NUMBER}
                                sed -i "s|image:.*|image: ${NEW_IMAGE_NAME}:${BUILD_NUMBER}|g" ./my-deploy/maven-deploy.yml
                                git add ./my-deploy/maven-deploy.yml
                                git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                                git push https://${NEW_GITHUB_TOKEN_VR}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:master
                            '''
                        } catch (Exception gitPushException) {
                            error "Git push failed: ${gitPushException.message}"
                        }
                    }
                }
            }
        }
    }
}
