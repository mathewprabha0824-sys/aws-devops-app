#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SSH_KEY="../../terraform/devops-key.pem"
SERVERS="3.110.195.50 3.111.29.97"

echo -e "${YELLOW}⏮️  Initiating Rollback...${NC}\n"

for server in $SERVERS; do
    echo "Rolling back on ${server}..."
    
    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ec2-user@${server} << 'SSHEOF'
sudo bash << 'ROLLBACK_SCRIPT'
if [ -d /var/www/html/backup ] && [ "$(ls -A /var/www/html/backup/*.php 2>/dev/null)" ]; then
    cp /var/www/html/backup/*.php /var/www/html/
    chown -R apache:apache /var/www/html
    systemctl restart httpd
    echo "✓ Rollback completed"
else
    echo "✗ No backup found"
    exit 1
fi
ROLLBACK_SCRIPT
SSHEOF
    
    echo -e "${GREEN}✓ Rolled back on ${server}${NC}"
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Rollback Completed!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
EOF

chmod +x pipeline/scripts/rollback.sh

Step 3: Create Jenkinsfile (For Documentation)
Even though you won't use Jenkins, create this file to show you understand the CI/CD pipeline concept:
bashcat > pipeline/Jenkinsfile << 'EOF'
pipeline {
    agent any
    
    environment {
        APP_NAME = 'devops-assessment-app'
        APP_VERSION = "${env.BUILD_NUMBER}"
        SERVERS = '3.110.195.50,3.111.29.97'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Checking out code...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo '📦 Building application...'
                sh '''
                    mkdir -p build
                    cp -r webapp/* build/
                    tar -czf ${APP_NAME}-${APP_VERSION}.tar.gz -C build .
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                sh '''
                    for file in webapp/*.php; do
                        php -l "$file"
                    done
                '''
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                echo '🚀 Deploying to staging...'
                sh '''
                    ./pipeline/scripts/simple-deploy.sh ${APP_VERSION} staging
                '''
            }
        }
        
        stage('Manual Approval') {
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
            }
        }
        
        stage('Deploy to Production') {
            steps {
                echo '🚀 Deploying to production...'
                sh '''
                    ./pipeline/scripts/simple-deploy.sh ${APP_VERSION} production
                '''
            }
        }
    }
    
    post {
        failure {
            echo '❌ Pipeline failed - Rolling back...'
            sh './pipeline/scripts/rollback.sh'
        }
    }
}