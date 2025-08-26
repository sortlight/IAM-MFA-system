#!/bin/bash

# This script automates setup like a DevOps pro—checks prereqs, starts services, sets env.


echo "Starting IAM MFA System Setup..."
if ! command -v docker &> /dev/null; then
    echo "Error: Docker not found. Install from https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 not found. Install from https://www.python.org/"
    exit 1
fi

echo "Installing Python dependencies..."
pip install -r ../requirements.txt || { echo "Pip install failed!"; exit 1; }
echo "Starting Keycloak via Docker..."
docker-compose up -d || { echo "Docker start failed!"; exit 1; }
sleep 10 
if curl -s -f http://localhost:8080 > /dev/null; then
    echo "Keycloak is up!"
else
    echo "Error: Keycloak not responding."
    exit 1
fi

# Prompt for secrets and create .env
if [ ! -f "../.env" ]; then
    cp ../.env.example ../.env
    read -p "Enter Client ID (default: flask-app): " client_id
    client_id=${client_id:-flask-app}
    read -p "Enter Client Secret (from Keycloak): " client_secret
    read -p "Enter Issuer URL (default: http://localhost:8080/realms/myrealm): " issuer
    issuer=${issuer:-http://localhost:8080/realms/myrealm}
    read -p "Enter Flask Secret Key (random recommended): " flask_secret
    flask_secret=${flask_secret:-$(openssl rand -hex 12)}

    sed -i "s/CLIENT_ID=.*/CLIENT_ID=$client_id/" ../.env
    sed -i "s/CLIENT_SECRET=.*/CLIENT_SECRET=$client_secret/" ../.env
    sed -i "s/ISSUER=.*/ISSUER=$issuer/" ../.env
    sed -i "s/FLASK_SECRET_KEY=.*/FLASK_SECRET_KEY=$flask_secret/" ../.env

    echo ".env created! Remember to configure Keycloak manually as per README."
else
    echo ".env exists—skipping creation."
fi

echo "Setup complete! Run 'python app.py' to start the app."
