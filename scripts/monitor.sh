#!/bin/bash

# monitors script-tails logs and checks health


echo "Starting IAM System Monitor..."


LOG_FILE="../audit.log"
APP_URL="http://localhost:5000"
KEYCLOAK_URL="http://localhost:8080"
INTERVAL=10  

while true; do
    echo "--- Recent Audit Logs ---"
    tail -n 10 "$LOG_FILE"
    if curl -s -f "$APP_URL" > /dev/null; then
        echo "$(date) - Flask App: Healthy"
    else
        echo "$(date) - Alert: Flask App down!" | tee -a "$LOG_FILE"
    fi

    if curl -s -f "$KEYCLOAK_URL" > /dev/null; then
        echo "$(date) - Keycloak: Healthy"
    else
        echo "$(date) - Alert: Keycloak down!" | tee -a "$LOG_FILE"
    fi

    sleep $INTERVAL
done
