#!/bin/bash
set -e

EC2_USER="ubuntu"
EC2_HOST="ec2-16-171-14-23.eu-north-1.compute.amazonaws.com"
KEY_FILE="diamondbarbershop.pem"

TIMESTAMP=$(date +%s)
LOCAL_JAR="backend/target/backend-0.0.1.jar"
REMOTE_JAR="backend-$TIMESTAMP.jar"

echo "🚀 Build..."

cd backend
mvn clean package -DskipTests
cd ..

echo "📤 Uploading new version..."

scp -i $KEY_FILE $LOCAL_JAR \
$EC2_USER@$EC2_HOST:/home/ubuntu/$REMOTE_JAR

echo "⚙️ Deploying..."

ssh -i $KEY_FILE $EC2_USER@$EC2_HOST << EOF

set -e

sudo mkdir -p /opt/myapp/releases

echo "📦 Moving new release..."
sudo mv /home/ubuntu/$REMOTE_JAR /opt/myapp/releases/

echo "🔗 Switching symlink (atomic swap)..."
sudo ln -sfn /opt/myapp/releases/$REMOTE_JAR /opt/myapp/current.jar

echo "🔁 Restarting app..."
sudo systemctl restart mpbe

echo "✅ Done"
EOF