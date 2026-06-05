#!/bin/bash

set -e

EC2_USER="ubuntu"
EC2_HOST="ec2-16-171-14-23.eu-north-1.compute.amazonaws.com"
KEY_FILE="diamondbarbershop.pem"

LOCAL_JAR="backend/target/backend-0.0.1.jar"
REMOTE_PATH="/opt/myapp/app.jar"

echo "🚀 Starting deployment..."

# =====================
# BUILD STEP (FIXED)
# =====================
echo "📦 Building application..."

cd backend
mvn clean package
cd ..

echo "✔ Build completed"

# =====================
# STOP OLD APP
# =====================
echo "🛑 Stopping old app..."

ssh -i $KEY_FILE $EC2_USER@$EC2_HOST << 'EOF'
sudo systemctl stop mpbe || true
EOF

# =====================
# COPY JAR
# =====================
echo "📤 Copying JAR to EC2..."

scp -i $KEY_FILE $LOCAL_JAR $EC2_USER@$EC2_HOST:/home/ubuntu/app.jar

# =====================
# DEPLOY ON SERVER
# =====================
echo "⚙️ Deploying on EC2..."

ssh -i $KEY_FILE $EC2_USER@$EC2_HOST << 'EOF'

sudo mkdir -p /opt/myapp
sudo mv /home/ubuntu/app.jar /opt/myapp/app.jar

echo "🔁 Restarting application..."

if systemctl list-units --type=service | grep -q mpbe; then
    sudo systemctl restart mpbe
else
    echo "No systemd service found, starting manually..."
    nohup java -jar /opt/myapp/app.jar > app.log 2>&1 &
fi

EOF

echo "✅ Deployment completed successfully!"