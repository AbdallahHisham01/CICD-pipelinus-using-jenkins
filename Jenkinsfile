pipeline {
    agent any
    environment {
        REACT_IMAGE = 'ahisham45/react'
        EXPRESS_IMAGE = 'ahisham45/express'
    }
    stages {

        // stage('Code Analysis') {
        //   environment {
        //         scannerHome = tool 'sonar'
        //     }
        //      steps {
        //          script {
        //              withSonarQubeEnv('sonar') {
        //                  sh """
        //                     ${scannerHome}/bin/sonar-scanner \
        //                      -Dsonar.projectKey=frontend \
        //                      -Dsonar.projectName=Frontend \
        //                      -Dsonar.projectVersion=1.0 \
        //                      -Dsonar.sources=./frontend
        //                  """
        //              }

        //              withSonarQubeEnv('sonar') {
        //                  sh """
        //                     ${scannerHome}/bin/sonar-scanner \
        //                     -Dsonar.projectKey=backend \
        //                      -Dsonar.projectName=Backend \
        //                      -Dsonar.projectVersion=1.0 \
        //                      -Dsonar.sources=./backend
        //                  """
        //             }
        //         }
        //     }
        // }

        stage('Dockerhub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                }
            }
        }

        stage('Build react image') {
            steps {
                sh 'docker build -t ${REACT_IMAGE} ./frontend'
            }
        }

        stage('Scan React Image with Trivy') {
            steps {
                script {
                def isVuln = sh( script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${REACT_IMAGE}", returnstatus: true )
                if (isVuln) {
                    error "react image is vuln."
                }
                }
            }
        }

        stage('Build express image') {
            steps {
                sh 'docker build -t ${EXPRESS_IMAGE} ./backend'
            }
        }

        stage('Scan express Image with Trivy') {
            steps {
                script {
                    def isVuln = sh( script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${EXPRESS_IMAGE}", returnstatus: true )
                    if (isVuln) {
                        error "react image is vuln."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    parallel(
                        react: {
                            sh "docker push ${REACT_IMAGE}"
                        },
                        express: {
                            sh "docker push ${EXPRESS_IMAGE}"
                        }
                    )
                }
            }
        }

        stage('Run MERN Helm Charts') {
            steps {   
                withEnv(["KUBECONFIG=/var/lib/jenkins/.kube/k3s.yaml"]) {
                    sh "helm upgrade --install mern ./k8s/mern-chart"                        
                    }
                }
            }
            stage('Run nginx Helm Charts') {
            when {
                changeset "**/k8s/nginx-ingress/**"
            }
            steps {
                withEnv(["KUBECONFIG=/var/lib/jenkins/.kube/k3s.yaml"]) {    
                    sh "helm install nginx ./k8s/nginx-ingress"
                 }
                }
            }
        }
    }

