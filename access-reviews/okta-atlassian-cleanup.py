import requests
import csv
from datetime import datetime, timedelta

# Okta API credentials
OKTA_API_TOKEN = 'your_okta_api_token'
OKTA_ORG_URL = 'https://your-okta-org.okta.com'  # Replace with your Okta domain

# Atlassian API credentials
ATLASSIAN_EMAIL = 'your_email@domain.com'
ATLASSIAN_API_TOKEN = 'your_atlassian_api_token'
ATLASSIAN_API_URL = "https://your-domain.atlassian.net/rest/api/3"

# Inactive period in days
INACTIVE_DAYS = 90

# Calculate the threshold date for inactivity
inactive_threshold_date = datetime.now() - timedelta(days=INACTIVE_DAYS)

# Set up headers for Okta API
okta_headers = {
    'Authorization': f'SSWS {OKTA_API_TOKEN}',
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

# Set up headers for Atlassian API
def get_atlassian_headers():
    auth = f"{ATLASSIAN_EMAIL}:{ATLASSIAN_API_TOKEN}"
    encoded_auth = base64.b64encode(auth.encode()).decode('ascii')
    return {'Authorization': f"Basic {encoded_auth}", 'Accept': 'application/json'}

# Function to fetch inactive users from Okta
def get_inactive_okta_users():
    url = f"{OKTA_ORG_URL}/api/v1/users"
    response = requests.get(url, headers=okta_headers)
    
    if response.status_code != 200:
        print("Error fetching users from Okta:", response.status_code, response.text)
        return []

    users = response.json()
    inactive_users = []

    for user in users:
        if 'lastLogin' in user and user['lastLogin']:
            last_login = datetime.strptime(user['lastLogin'], "%Y-%m-%dT%H:%M:%S.%fZ")
            if last_login < inactive_threshold_date:
                inactive_users.append({
                    'id': user['id'],
                    'email': user['profile']['email'],
                    'last_login': last_login
                })

    return inactive_users

# Function to write a CSV report
def write_inactive_users_report(inactive_users):
    with open('inactive_users_report.csv', 'w', newline='') as csvfile:
        fieldnames = ['Okta ID', 'Email', 'Last Login']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        writer.writeheader()
        for user in inactive_users:
            writer.writerow({
                'Okta ID': user['id'],
                'Email': user['email'],
                'Last Login': user['last_login']
            })
    print("Inactive users report generated: inactive_users_report.csv")

# Function to deactivate a user in Okta
def deactivate_okta_user(user_id):
    url = f"{OKTA_ORG_URL}/api/v1/users/{user_id}/lifecycle/deactivate"
    response = requests.post(url, headers=okta_headers)
    
    if response.status_code == 200:
        print(f"Successfully deactivated Okta user ID: {user_id}")
    else:
        print(f"Failed to deactivate Okta user ID: {user_id}", response.status_code, response.text)

# Function to deactivate a user in Atlassian
def deactivate_atlassian_user(email):
    # Fetch Atlassian user by email to get their account ID
    search_url = f"{ATLASSIAN_API_URL}/user/search"
    headers = get_atlassian_headers()
    params = {'query': email}
    
    response = requests.get(search_url, headers=headers, params=params)
    
    if response.status_code == 200 and response.json():
        account_id = response.json()[0]['accountId']
        disable_url = f"{ATLASSIAN_API_URL}/user?accountId={account_id}"
        
        # Set active status to False
        deactivate_response = requests.put(disable_url, headers=headers, json={'active': False})
        
        if deactivate_response.status_code == 204:
            print(f"Successfully deactivated Atlassian user with email: {email}")
        else:
            print(f"Failed to deactivate Atlassian user with email: {email}", deactivate_response.status_code, deactivate_response.text)
    else:
        print(f"Atlassian user not found or error retrieving user with email: {email}", response.status_code, response.text)

# Main function to process inactive users
def process_inactive_users():
    inactive_okta_users = get_inactive_okta_users()
    
    # Generate report
    write_inactive_users_report(inactive_okta_users)
    
    # Optionally, deactivate users
    for user in inactive_okta_users:
        deactivate_okta_user(user['id'])
        deactivate_atlassian_user(user['email'])

# Run the process
process_inactive_users()
