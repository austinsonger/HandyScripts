import requests

# Okta API credentials
OKTA_API_TOKEN = 'your_okta_api_token'
OKTA_ORG_URL = 'https://your-okta-org.okta.com'  # Replace with your Okta domain

# Atlassian API credentials
ATLASSIAN_EMAIL = 'your_email@domain.com'
ATLASSIAN_API_TOKEN = 'your_atlassian_api_token'
ATLASSIAN_API_URL = "https://your-domain.atlassian.net/rest/api/3"

# Define role-to-group mappings
ROLE_TO_GROUP_MAP = {
    "Engineer": "engineering-team",
    "Manager": "managers",
    # Add more mappings as needed
}

# Headers for Okta API
okta_headers = {
    'Authorization': f'SSWS {OKTA_API_TOKEN}',
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

# Function to get headers for Atlassian API
def get_atlassian_headers():
    import base64
    auth = f"{ATLASSIAN_EMAIL}:{ATLASSIAN_API_TOKEN}"
    encoded_auth = base64.b64encode(auth.encode()).decode('ascii')
    return {'Authorization': f"Basic {encoded_auth}", 'Accept': 'application/json', 'Content-Type': 'application/json'}

# Function to fetch users and roles from Okta
def get_okta_users_and_roles():
    url = f"{OKTA_ORG_URL}/api/v1/users"
    response = requests.get(url, headers=okta_headers)
    
    if response.status_code == 200:
        users = response.json()
        user_roles = {}
        
        for user in users:
            email = user['profile'].get('email')
            role = user['profile'].get('role')  # Assuming 'role' is defined in Okta profile attributes
            if email and role:
                user_roles[email] = role
        
        return user_roles
    else:
        print("Error fetching users from Okta:", response.status_code, response.text)
        return {}

# Function to fetch Atlassian user by email and check group membership
def get_atlassian_user_groups(email):
    url = f"{ATLASSIAN_API_URL}/user/search"
    headers = get_atlassian_headers()
    params = {'query': email}
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200 and response.json():
        user = response.json()[0]
        account_id = user['accountId']
        
        # Fetch user groups
        groups_url = f"{ATLASSIAN_API_URL}/user/groups?accountId={account_id}"
        groups_response = requests.get(groups_url, headers=headers)
        
        if groups_response.status_code == 200:
            groups = [group['name'] for group in groups_response.json()]
            return account_id, groups
        else:
            print(f"Error fetching groups for {email}:", groups_response.status_code, groups_response.text)
            return account_id, []
    else:
        print(f"Atlassian user not found for email: {email}")
        return None, []

# Function to add a user to an Atlassian group
def add_user_to_atlassian_group(account_id, group_name):
    url = f"{ATLASSIAN_API_URL}/group/user?groupname={group_name}"
    headers = get_atlassian_headers()
    data = {'accountId': account_id}
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 201:
        print(f"Added user {account_id} to group {group_name}")
    else:
        print(f"Failed to add user {account_id} to group {group_name}", response.status_code, response.text)

# Function to remove a user from an Atlassian group
def remove_user_from_atlassian_group(account_id, group_name):
    url = f"{ATLASSIAN_API_URL}/group/user?groupname={group_name}&accountId={account_id}"
    headers = get_atlassian_headers()
    response = requests.delete(url, headers=headers)
    
    if response.status_code == 204:
        print(f"Removed user {account_id} from group {group_name}")
    else:
        print(f"Failed to remove user {account_id} from group {group_name}", response.status_code, response.text)

# Function to synchronize roles from Okta to Atlassian groups
def sync_roles():
    # Fetch users and roles from Okta
    user_roles = get_okta_users_and_roles()
    
    for email, okta_role in user_roles.items():
        atlassian_group = ROLE_TO_GROUP_MAP.get(okta_role)
        
        if atlassian_group:
            account_id, current_groups = get_atlassian_user_groups(email)
            
            if account_id:
                # If user should be in the group but isn't, add them
                if atlassian_group not in current_groups:
                    add_user_to_atlassian_group(account_id, atlassian_group)
                
                # Remove user from any group they shouldn't be in, according to Okta
                for group in current_groups:
                    if group != atlassian_group and group in ROLE_TO_GROUP_MAP.values():
                        remove_user_from_atlassian_group(account_id, group)

# Run the sync
sync_roles()
