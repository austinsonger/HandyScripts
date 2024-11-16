import requests
import json
import base64

# Okta API credentials
OKTA_API_TOKEN = 'your_okta_api_token'
OKTA_ORG_URL = 'https://your-okta-org.okta.com'  # Replace with your Okta domain

# Atlassian API credentials
ATLASSIAN_EMAIL = 'your_email@domain.com'
ATLASSIAN_API_TOKEN = 'your_atlassian_api_token'
ATLASSIAN_API_URL = "https://your-domain.atlassian.net/rest/api/3"

# Headers for Okta API
okta_headers = {
    'Authorization': f'SSWS {OKTA_API_TOKEN}',
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

# Function to get headers for Atlassian API
def get_atlassian_headers():
    auth = f"{ATLASSIAN_EMAIL}:{ATLASSIAN_API_TOKEN}"
    encoded_auth = base64.b64encode(auth.encode()).decode('ascii')
    return {'Authorization': f"Basic {encoded_auth}", 'Accept': 'application/json', 'Content-Type': 'application/json'}

# Function to fetch users from Okta
def get_okta_users():
    url = f"{OKTA_ORG_URL}/api/v1/users"
    response = requests.get(url, headers=okta_headers)
    
    if response.status_code == 200:
        return response.json()
    else:
        print("Error fetching users from Okta:", response.status_code, response.text)
        return []

# Function to get Atlassian user by email
def get_atlassian_user(email):
    url = f"{ATLASSIAN_API_URL}/user/search"
    headers = get_atlassian_headers()
    params = {'query': email}
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200 and response.json():
        return response.json()[0]  # Return the first matching user
    else:
        print(f"Atlassian user not found for email: {email}")
        return None

# Function to update Atlassian user attributes
def update_atlassian_user(account_id, updated_fields):
    url = f"{ATLASSIAN_API_URL}/user?accountId={account_id}"
    headers = get_atlassian_headers()
    response = requests.put(url, headers=headers, json=updated_fields)
    
    if response.status_code == 204:
        print(f"Successfully updated Atlassian user {account_id}")
    else:
        print(f"Failed to update Atlassian user {account_id}", response.status_code, response.text)

# Function to synchronize attributes from Okta to Atlassian
def sync_user_attributes():
    okta_users = get_okta_users()
    
    for user in okta_users:
        # Extract relevant attributes from Okta user
        email = user['profile'].get('email')
        department = user['profile'].get('department')
        job_title = user['profile'].get('title')

        # Get the corresponding Atlassian user
        atlassian_user = get_atlassian_user(email)
        
        if atlassian_user:
            # Prepare the updated fields for Atlassian
            # Check if Atlassian fields match Okta values to avoid unnecessary updates
            atlassian_account_id = atlassian_user['accountId']
            atlassian_department = atlassian_user.get('department')
            atlassian_job_title = atlassian_user.get('job_title')

            updated_fields = {}
            if department and department != atlassian_department:
                updated_fields['department'] = department
            if job_title and job_title != atlassian_job_title:
                updated_fields['title'] = job_title

            # Update Atlassian user if there are changes
            if updated_fields:
                update_atlassian_user(atlassian_account_id, updated_fields)

# Run the sync
sync_user_attributes()
