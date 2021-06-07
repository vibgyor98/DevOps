pipeline {
    agent any
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
        stage('Build Image'){
            steps{
                bat "docker build -t souravkar/assignment04:${BUILD_NUMBER} ."
            }
        }
        stage('Docker Deployment'){
            steps{
                bat "docker run --name souravkar/assignment04 -d -p 8080:3000 assignment04image:${BUILD_NUMBER}"
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