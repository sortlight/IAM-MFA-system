import requests
import logging
import time
from random import choice

logging.basicConfig(filename='../audit.log', level=logging.WARNING, 
                    format='%(asctime)s - %(levelname)s - %(message)s')
 
creds = [
    ('user1', 'wrongpass'), ('user1', 'test123'),
    ('admin1', 'badpass'), ('admin1', 'admin123')
] * 20

def simulate_stuffing(url, max_attempts=100):
    attempts = 0
    successes = 0
    for _ in range(max_attempts):
        username, password = choice(creds)
        attempts += 1
        try:
            # Note: uses full OIDC params.
            params = {'client_id': 'flask-app', 'response_type': 'code', 'scope': 'openid', 'redirect_uri': 'http://localhost:5000/oidc/callback'}
            response = requests.post(url, data={'username': username, 'password': password}, params=params)
            if response.status_code == 200 and 'access_token' in response.text:
                successes += 1
                logging.warning(f"Success: {username}")
            else:
                logging.warning(f"Fail: {username}")
            time.sleep(0.5)
        except Exception as e:
            logging.error(f"Error: {e}")
    print(f"Attempts: {attempts}, Successes: {successes} (Should be 0 with MFA!)")

if __name__ == '__main__':
    url = 'http://localhost:8080/realms/myrealm/protocol/openid-connect/token'  # Token endpoint for sim
    simulate_stuffing(url)
