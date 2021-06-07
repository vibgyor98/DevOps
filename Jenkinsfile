pipeline {
    agent any
    environment {
        dockerImage = ''
        registry = 'souravkar/assignment04'
        registryCredential = 'Docker-Credential'
    }
    tools {
        maven "Maven"
    }
    stages {
        stage("code checkout") {
            steps {
                git url: 'https://github.com/vibgyor98/devops'
            }
        }
        stage("code build") {
            steps {
                bat "mvn clean install package"
            }
        }
        stage("code test") {
            steps {
                bat "mvn test"
            }
        }
        stage("Sonar Analysis") {
            steps {
                withSonarQubeEnv("SonarQube") {
                    bat "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar"
                }
            }
        }
        stage("Quality Gate") {
            steps {
                sleep(10)
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage("Deploy"){
            steps{
                deploy adapters: [tomcat7(credentialsId: 'tomcat-cred', path: '', url: 'http://localhost:8085/')], contextPath: 'Addition', war: '**/*.war'
            }
        }
        stage("Upload to artifactory") {
            steps {
                rtMavenDeployer (
                    id: "admin",
                    serverId: "artifactory-server",
                    releaseRepo: "Assignment04",
                    snapshotRepo: "Assignment04"
                )
                rtMavenRun (
                    pom: "pom.xml",
                    goals: "clean install",
                    deployerId: "admin"
                )
                rtPublishBuildInfo (
                    serverId: "artifactory-server"
                )
            }
        } 
        stage('Build Docker-Image') {
            steps {
                script {
                    dockerImage = docker.build registry
                }
            }
        }
        stage('Upload Image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Stop Container') {
            steps {
                sh 'docker ps -f name=assignment04 -q | xargs --no-run-if-empty docker container stop'
                sh 'docker container ls -a -fname=assignment04 -q | xargs -r docker container rm'
            }
        }
        stage('Run Container') {
            steps {
                script {
                    dockerImage.run("-p 8080:3000 --rm --name assignment04")
                }
            }
        }
    }
    post {
        always {
            bat "echo always"
        }
        success {
            bat "echo success"
        }
        failure {
            bat "echo failure"
        }
    }
}