import requests

# Okta API credentials
OKTA_API_TOKEN = 'your_okta_api_token'
OKTA_ORG_URL = 'https://your-okta-org.okta.com'  

# Atlassian API credentials
ATLASSIAN_EMAIL = 'your_email@domain.com'
ATLASSIAN_API_TOKEN = 'your_atlassian_api_token'
ATLASSIAN_API_URL = "https://your-domain.atlassian.net/rest/api/3"

#  #  #  #  #  #  #  #  #  # #  #  #  #  #  #  #  #  #  
# Define role-to-group mappings
# Okta Role "Engineering" maps to Atlassian Group "engineering-project-access"
# Okta Department "Sales" maps to Atlassian Group "sales-project-access"
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
ROLE_DEPARTMENT_TO_GROUP_MAP = {
    "Engineering": "engineering-project-access",
    "Sales": "sales-project-access",
    "Marketing": "marketing-project-access",
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

# Function to fetch users and their roles/departments from Okta
def get_okta_users_and_roles():
    url = f"{OKTA_ORG_URL}/api/v1/users"
    response = requests.get(url, headers=okta_headers)
    
    if response.status_code == 200:
        users = response.json()
        user_roles = {}
        
        for user in users:
            email = user['profile'].get('email')
            department = user['profile'].get('department')  # Assuming 'department' is defined in Okta profile attributes
            role = user['profile'].get('role')  # Assuming 'role' is also defined in Okta profile attributes
            if email:
                user_roles[email] = {'department': department, 'role': role}
        
        return user_roles
    else:
        print("Error fetching users from Okta:", response.status_code, response.text)
        return {}

# Function to get a user's group membership in Atlassian
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

# Function to synchronize permissions based on Okta roles/departments
def sync_rbac():
    # Fetch users and roles/departments from Okta
    user_roles = get_okta_users_and_roles()
    
    for email, attributes in user_roles.items():
        # Determine the target Atlassian group based on role or department
        okta_department = attributes.get('department')
        okta_role = attributes.get('role')
        target_group = ROLE_DEPARTMENT_TO_GROUP_MAP.get(okta_department) or ROLE_DEPARTMENT_TO_GROUP_MAP.get(okta_role)
        
        if target_group:
            account_id, current_groups = get_atlassian_user_groups(email)
            
            if account_id:
                # Add user to the target group if they are not already in it
                if target_group not in current_groups:
                    add_user_to_atlassian_group(account_id, target_group)
                
                # Remove user from any group they shouldn't belong to, according to their role/department
                for group in current_groups:
                    if group != target_group and group in ROLE_DEPARTMENT_TO_GROUP_MAP.values():
                        remove_user_from_atlassian_group(account_id, group)

# Run the sync
sync_rbac()
