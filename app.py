from flask import Flask, render_template, redirect, url_for, session, request, jsonify
from flask_oidc import OpenIDConnect
import logging
import os
from dotenv import load_dotenv


load_dotenv()


logging.basicConfig(filename='audit.log', level=logging.INFO, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', os.urandom(24))  # Use env or random

app.config.update({
    'OIDC_CLIENT_SECRETS': {
        'client_id': os.getenv('CLIENT_ID'),
        'client_secret': os.getenv('CLIENT_SECRET'),
        'issuer': os.getenv('ISSUER')
    },
    'OIDC_ID_TOKEN_COOKIE_SECURE': False,  # Dev only
    'OIDC_REQUIRE_VERIFIED_EMAIL': False,
    'OIDC_USER_INFO_ENABLED': True,
    'OIDC_OPENID_REALM': 'myrealm',
    'OIDC_SCOPES': ['openid', 'email', 'profile'],
    'OIDC_INTROSPECTION_AUTH_METHOD': 'client_secret_post',
    'OVERWRITE_REDIRECT_URI': 'http://localhost:5000/oidc/callback'
})

oidc = OpenIDConnect(app)

@app.route('/')
def home():
    if oidc.user_loggedin:
        return redirect(url_for('dashboard'))
    return render_template('login.html')

@app.route('/login')
@oidc.require_login
def login():
    return redirect(url_for('dashboard'))

@app.route('/dashboard')
@oidc.require_login
def dashboard():
    user_info = oidc.user_getinfo(['preferred_username', 'email', 'roles'])
    roles = user_info.get('roles', [])
    if 'admin' in roles:
        content = "Welcome, Admin! Full access."
    else:
        content = "Welcome, User! Basic view."
    logging.info(f"User {user_info['preferred_username']} accessed dashboard with roles: {roles}")
    return render_template('dashboard.html', content=content, username=user_info['preferred_username'])

@app.route('/logout')
def logout():
    oidc.logout()
    return redirect(url_for('home'))

@app.route('/oidc/callback')
def oidc_callback():
    logging.info("OIDC callback successful")
    return redirect(url_for('dashboard'))

@app.route('/api/protected')
@oidc.require_login
def protected_api():
    return jsonify({"message": "Protected! JWT validated."})

if __name__ == '__main__':
    app.run(debug=True)
