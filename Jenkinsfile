pipeline {
    agent any
    environment {
        REACT_IMAGE = 'ahisham45/react'
        EXPRESS_IMAGE = 'ahisham45/express'
    }
    stages {

        stage('Code Analysis') {
          environment {
                scannerHome = tool 'sonar'
            }
             steps {
                 script {
                     withSonarQubeEnv('sonar') {
                         sh """
                            ${scannerHome}/bin/sonar-scanner \
                             -Dsonar.projectKey=frontend \
                             -Dsonar.projectName=Frontend \
                             -Dsonar.projectVersion=1.0 \
                             -Dsonar.sources=./frontend
                         """
                     }
        
                     withSonarQubeEnv('sonar') {
                         sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=backend \
                             -Dsonar.projectName=Backend \
                             -Dsonar.projectVersion=1.0 \
                             -Dsonar.sources=./backend
                         """
                    }
                }
            }
        }

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

        stage('Build images') {
            steps {
                script {
                    parallel (
                        react: {
                            sh "docker build -t ${REACT_IMAGE} ./frontend"
                        },
                        express: {
                            sh "docker build -t ${EXPRESS_IMAGE} ./backend"
                        }
                    )
                }
            }
        }

        stage('Scan Images with Trivy') {
            steps {
                script {
                    parallel (
                        react: {
                            def isVuln = sh(script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${REACT_IMAGE}", returnStatus: true)
                            if (isVuln != 0) {
                                emailext(
                                    to: 'abdallahhisham462@gmail.com',
                                    subject: "React Image Is Vulnerable",
                                    body: "React image is vulnerable."
                                )
                                error "React image is vulnerable."
                            }
                        },
                        express: {
                            def isVuln = sh(script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${EXPRESS_IMAGE}", returnStatus: true)
                            if (isVuln != 0) {
                                emailext(
                                    to: 'abdallahhisham462@gmail.com',
                                    subject: "Express Image Is Vulnerable",
                                    body: "Express image is vulnerable."
                                )
                                error "Express image is vulnerable."
                            }
                        }
                    )
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
