#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

APP_NAME="devops-assessment-app"
VERSION="${1:-1.0.0}"
ENVIRONMENT="${2:-staging}"
SSH_KEY="../../terraform/devops-key.pem"
SERVERS="3.110.195.50 3.111.29.97"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WEBAPP_DIR="${SCRIPT_DIR}/../../webapp"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   DevOps Assessment - CI/CD Deploy    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if webapp exists
if [ ! -d "$WEBAPP_DIR" ]; then
    echo -e "${RED}✗ webapp directory not found at $WEBAPP_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Step 1: Building Application...${NC}"
mkdir -p build
cp "$WEBAPP_DIR"/*.php build/
echo "${VERSION}" > build/version.txt
tar -czf "${APP_NAME}-${VERSION}.tar.gz" -C build .
echo -e "${GREEN}✓ Build completed${NC}\n"

echo -e "${YELLOW}🧪 Step 2: Running Tests...${NC}"
for file in build/*.php; do
    php -l "$file" > /dev/null 2>&1 && echo -e "${GREEN}✓ $(basename $file) - OK${NC}"
done
echo ""

echo -e "${YELLOW}🚀 Step 3: Deploying to ${ENVIRONMENT}...${NC}"
for server in $SERVERS; do
    echo "Deploying to ${server}..."
    scp -o StrictHostKeyChecking=no -i "$SSH_KEY" \
        "${APP_NAME}-${VERSION}.tar.gz" ec2-user@${server}:/tmp/
    
    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" ec2-user@${server} << EOF
        sudo tar -xzf /tmp/${APP_NAME}-${VERSION}.tar.gz -C /var/www/html/
        sudo chown -R apache:apache /var/www/html
        sudo systemctl restart httpd
        rm -f /tmp/${APP_NAME}-${VERSION}.tar.gz
EOF
    echo -e "${GREEN}✓ Deployed to ${server}${NC}"
done

echo -e "\n${YELLOW}🏥 Step 4: Running Health Checks...${NC}"
sleep 3
for server in $SERVERS; do
    if curl -f -s --connect-timeout 5 http://${server}/health.php > /dev/null; then
        echo -e "${GREEN}✓ ${server} is healthy${NC}"
    else
        echo -e "${RED}✗ ${server} health check failed${NC}"
    fi
done

rm -rf build "${APP_NAME}-${VERSION}.tar.gz"

echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Deployment Complete!              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
