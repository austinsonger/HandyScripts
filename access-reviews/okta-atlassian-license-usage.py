import requests
import smtplib
from email.mime.text import MIMEText

# Configuration for license limits and alert thresholds
OKTA_LICENSE_LIMIT = 100
ATLASSIAN_LICENSE_LIMIT = 100
ALERT_THRESHOLD_PERCENTAGE = 90  # Alert if 90% or more licenses are in use

# Okta API credentials
OKTA_API_TOKEN = 'your_okta_api_token'
OKTA_ORG_URL = 'https://your-okta-org.okta.com'  # Replace with your Okta domain

# Atlassian API credentials
ATLASSIAN_EMAIL = 'your_email@domain.com'
ATLASSIAN_API_TOKEN = 'your_atlassian_api_token'
ATLASSIAN_API_URL = "https://your-domain.atlassian.net/rest/api/3"

# Email configuration for alerts
ALERT_EMAIL_FROM = 'your_alert_email@domain.com'
ALERT_EMAIL_TO = 'team_lead@domain.com'
SMTP_SERVER = 'smtp.your-email-provider.com'
SMTP_PORT = 587
SMTP_USERNAME = 'your_smtp_username'
SMTP_PASSWORD = 'your_smtp_password'

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
    return {'Authorization': f"Basic {encoded_auth}", 'Accept': 'application/json'}

# Function to fetch active user count from Okta
def get_active_okta_users_count():
    url = f"{OKTA_ORG_URL}/api/v1/users"
    params = {'filter': 'status eq "ACTIVE"'}
    response = requests.get(url, headers=okta_headers, params=params)
    
    if response.status_code == 200:
        users = response.json()
        return len(users)
    else:
        print("Error fetching active users from Okta:", response.status_code, response.text)
        return 0

# Function to fetch active user count from Atlassian
def get_active_atlassian_users_count():
    url = f"{ATLASSIAN_API_URL}/users/search"
    headers = get_atlassian_headers()
    params = {'active': True}
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200:
        users = response.json()
        return len(users)
    else:
        print("Error fetching active users from Atlassian:", response.status_code, response.text)
        return 0

# Function to check and alert if thresholds are exceeded
def check_and_alert(okta_count, atlassian_count):
    okta_usage_percentage = (okta_count / OKTA_LICENSE_LIMIT) * 100
    atlassian_usage_percentage = (atlassian_count / ATLASSIAN_LICENSE_LIMIT) * 100

    alert_message = ""

    if okta_usage_percentage >= ALERT_THRESHOLD_PERCENTAGE:
        alert_message += f"Okta license usage is at {okta_usage_percentage:.2f}% ({okta_count} of {OKTA_LICENSE_LIMIT}).\n"

    if atlassian_usage_percentage >= ALERT_THRESHOLD_PERCENTAGE:
        alert_message += f"Atlassian license usage is at {atlassian_usage_percentage:.2f}% ({atlassian_count} of {ATLASSIAN_LICENSE_LIMIT}).\n"

    if alert_message:
        print("Threshold exceeded. Sending alert...")
        send_alert_email(alert_message)

    return {
        "okta_count": okta_count,
        "atlassian_count": atlassian_count,
        "okta_usage_percentage": okta_usage_percentage,
        "atlassian_usage_percentage": atlassian_usage_percentage
    }

# Function to send email alert
def send_alert_email(message):
    msg = MIMEText(message)
    msg['Subject'] = "License Usage Alert"
    msg['From'] = ALERT_EMAIL_FROM
    msg['To'] = ALERT_EMAIL_TO

    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USERNAME, SMTP_PASSWORD)
        server.sendmail(ALERT_EMAIL_FROM, ALERT_EMAIL_TO, msg.as_string())
    print("Alert email sent.")

# Function to generate and print the license usage report
def generate_license_usage_report(report_data):
    report = (
        f"License Usage Report:\n\n"
        f"Okta Active Users: {report_data['okta_count']} / {OKTA_LICENSE_LIMIT} "
        f"({report_data['okta_usage_percentage']:.2f}%)\n"
        f"Atlassian Active Users: {report_data['atlassian_count']} / {ATLASSIAN_LICENSE_LIMIT} "
        f"({report_data['atlassian_usage_percentage']:.2f}%)\n"
    )
    print(report)

# Main function to run the license monitoring
def monitor_license_usage():
    okta_count = get_active_okta_users_count()
    atlassian_count = get_active_atlassian_users_count()
    report_data = check_and_alert(okta_count, atlassian_count)
    generate_license_usage_report(report_data)

# Run the monitor function
monitor_license_usage()
