#!groovy

pipeline {
    agent any

    parameters {
        choice(name: 'LOAD_BALANCER_NAME', description: 'Load balancer name.', choices: ['', 'DA-ALB1', 'OP-ALB1', 'PC-ALB1', 'PERF-ALB1', 'PT-ALB1', 'Production-ALB1', 'QA-ALB1', 'QB-ALB1', 'ST-ALB1'])
        choice(name: 'ACTION', description: 'Action to take on load balancer name.', choices: ['', 'create', 'destroy'])
    }

    stages {
        stage('run lb_maintenance') {
            steps {
                sh('./lb_maintenance/lb_maintenance.sh ${ACTION} ${LOAD_BALANCER_NAME}')
            }
        }
    }
}
