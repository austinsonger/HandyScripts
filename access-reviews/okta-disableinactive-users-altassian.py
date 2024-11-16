import requests
import base64
import os

# Okta API credentials
OKTA_API_KEY = os.getenv('OKTA_API_KEY')
OKTA_DOMAIN = os.getenv('OKTA_DOMAIN')

# Atlassian API credentials
ATLASSIAN_DOMAIN = os.getenv("ATLASSIAN_DOMAIN")
ATLASSIAN_EMAIL = os.getenv("ATLASSIAN_EMAIL")
ATLASSIAN_API_TOKEN = os.getenv("ATLASSIAN_API_TOKEN")

# Okta headers
okta_headers = {
    'Authorization': f'SSWS {OKTA_API_KEY}',
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

# Function to get deactivated Okta users
def get_deactivated_okta_users():
    url = f"https://{OKTA_DOMAIN}.okta.com/api/v1/users"
    params = {'filter': 'status eq "DEPROVISIONED"'}
    response = requests.get(url, headers=okta_headers, params=params)
    
    if response.status_code == 200:
        users = response.json()
        return [user['profile']['email'] for user in users if user['status'] == 'DEPROVISIONED']
    else:
        print("Error fetching users from Okta:", response.status_code, response.text)
        return []

# Function to get Atlassian headers
def get_atlassian_headers():
    auth = f"{ATLASSIAN_EMAIL}:{ATLASSIAN_API_TOKEN}"
    encoded_auth = base64.b64encode(auth.encode()).decode('ascii')
    return {'Authorization': f"Basic {encoded_auth}", 'Accept': 'application/json'}

# Function to get active Atlassian users
def get_active_atlassian_users():
    url = f"https://{ATLASSIAN_DOMAIN}.atlassian.net/rest/api/3/users/search"
    headers = get_atlassian_headers()
    params = {'active': True}
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200:
        users = response.json()
        return {user['emailAddress']: user['accountId'] for user in users if user['active']}
    else:
        print("Error fetching users from Atlassian:", response.status_code, response.text)
        return {}

# Function to disable a user in Atlassian
def disable_atlassian_user(account_id):
    url = f"https://{ATLASSIAN_DOMAIN}.atlassian.net/rest/api/3/user"
    headers = get_atlassian_headers()
    params = {'accountId': account_id}
    data = {'active': False}
    response = requests.put(url, headers=headers, params=params, json=data)
    
    if response.status_code == 204:
        print(f"Successfully disabled Atlassian user with account ID: {account_id}")
    else:
        print(f"Failed to disable Atlassian user with account ID: {account_id}", response.status_code, response.text)

# Processing deactivated Okta users
deactivated_okta_users = get_deactivated_okta_users()
active_atlassian_users = get_active_atlassian_users()

def process_deactivated_users():
    for user_email in deactivated_okta_users:
        if user_email in active_atlassian_users:
            disable_atlassian_user(active_atlassian_users[user_email])

process_deactivated_users()
