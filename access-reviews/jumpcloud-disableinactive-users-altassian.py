import requests
import base64

# Jumpcloud API credentials
JUMPCLOUD_API_KEY = os.getenv('JUMPCLOUD_API_KEY')

# Atlassian API credential
ATLASSIAN_DOMAIN = os.getenv("ATLASSIAN_DOMAIN")
ATLASSIAN_EMAIL = os.getenv("ATLASSIAN_EMAIL")
ATLASSIAN_API_TOKEN = os.getenv("ATLASSIAN_API_TOKEN")


# Jumpcloud headers
jumpcloud_headers = {
    'x-api-key': JUMPCLOUD_API_KEY,
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

# Function to get deactivated Jumpcloud users
def get_deactivated_jumpcloud_users():
    url = "https://api.jumpcloud.com/api/systemusers"
    params = {'filter': 'account_locked:eq:true'}
    response = requests.get(url, headers=jumpcloud_headers, params=params)
    
    if response.status_code == 200:
        users = response.json()['results']
        return [user['email'] for user in users if not user['activated']]
    else:
        print("Error fetching users from Jumpcloud:", response.status_code, response.text)
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

# Processing deactivated Jumpcloud users
deactivated_jumpcloud_users = get_deactivated_jumpcloud_users()
active_atlassian_users = get_active_atlassian_users()

def process_deactivated_users():
    for user_email in deactivated_jumpcloud_users:
        if user_email in active_atlassian_users:
            disable_atlassian_user(active_atlassian_users[user_email])

process_deactivated_users()
