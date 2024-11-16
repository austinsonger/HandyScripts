import requests
from datetime import datetime, timedelta

# Okta API credentials
OKTA_API_TOKEN = 'your_okta_api_token'
OKTA_ORG_URL = 'https://your-okta-org.okta.com'  # Replace with your Okta domain

# Slack Webhook URL
SLACK_WEBHOOK_URL = 'your_slack_webhook_url'

# Headers for Okta API
okta_headers = {
    'Authorization': f'SSWS {OKTA_API_TOKEN}',
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

# Calculate the date range for the last 24 hours
end_time = datetime.now()
start_time = end_time - timedelta(hours=24)

# Format timestamps in ISO 8601 for Okta API query
start_time_iso = start_time.strftime('%Y-%m-%dT%H:%M:%SZ')
end_time_iso = end_time.strftime('%Y-%m-%dT%H:%M:%SZ')

# Function to fetch recent admin-level events from Okta
def get_recent_admin_events():
    url = f"{OKTA_ORG_URL}/api/v1/logs"
    params = {
        'since': start_time_iso,
        'until': end_time_iso,
        'filter': 'eventType eq "application.lifecycle.update" or eventType eq "policy.lifecycle.update" or eventType eq "user.lifecycle.suspend" or eventType eq "user.lifecycle.activate" or eventType eq "group.lifecycle.create"',
        'limit': 1000
    }
    response = requests.get(url, headers=okta_headers, params=params)
    
    if response.status_code == 200:
        return response.json()
    else:
        print("Error fetching events from Okta:", response.status_code, response.text)
        return []

# Function to process Okta events into a summary
def summarize_admin_events(events):
    summary = {
        'app_updates': [],
        'policy_updates': [],
        'user_status_changes': [],
        'group_changes': []
    }

    for event in events:
        event_type = event['eventType']
        admin_actor = event['actor']['displayName']
        target = event['target'][0]['displayName'] if event['target'] else 'Unknown'
        timestamp = event['published']

        if event_type == "application.lifecycle.update":
            summary['app_updates'].append((admin_actor, target, timestamp))
        elif event_type == "policy.lifecycle.update":
            summary['policy_updates'].append((admin_actor, target, timestamp))
        elif event_type in ["user.lifecycle.suspend", "user.lifecycle.activate"]:
            summary['user_status_changes'].append((admin_actor, target, timestamp, event_type))
        elif event_type == "group.lifecycle.create":
            summary['group_changes'].append((admin_actor, target, timestamp))

    return summary

# Function to format the summary as a Slack message
def format_slack_message(summary):
    message = "*End-of-Day Compliance Review Summary: Admin-Level Changes*\n\n"

    if summary['app_updates']:
        message += "*Application Updates:*\n"
        for admin, target, time in summary['app_updates']:
            message += f" - {admin} updated {target} at {time}\n"
    else:
        message += "*Application Updates:* None\n"

    if summary['policy_updates']:
        message += "\n*Policy Updates:*\n"
        for admin, target, time in summary['policy_updates']:
            message += f" - {admin} updated policy {target} at {time}\n"
    else:
        message += "\n*Policy Updates:* None\n"

    if summary['user_status_changes']:
        message += "\n*User Status Changes:*\n"
        for admin, target, time, action in summary['user_status_changes']:
            action_text = "suspended" if action == "user.lifecycle.suspend" else "activated"
            message += f" - {admin} {action_text} {target} at {time}\n"
    else:
        message += "\n*User Status Changes:* None\n"

    if summary['group_changes']:
        message += "\n*Group Changes:*\n"
        for admin, target, time in summary['group_changes']:
            message += f" - {admin} created or modified group {target} at {time}\n"
    else:
        message += "\n*Group Changes:* None\n"

    return message

# Function to send the summary message to Slack
def send_slack_message(message):
    payload = {
        'text': message
    }
    response = requests.post(SLACK_WEBHOOK_URL, json=payload)
    
    if response.status_code == 200:
        print("Slack message sent successfully.")
    else:
        print("Failed to send message to Slack:", response.status_code, response.text)

# Main function to run the end-of-day compliance summary
def compliance_review_summary():
    # Fetch events from Okta
    events = get_recent_admin_events()
    
    # Process events into a summary
    summary = summarize_admin_events(events)
    
    # Format the summary message
    slack_message = format_slack_message(summary)
    
    # Send the message to Slack
    send_slack_message(slack_message)

# Run the compliance review summary
compliance_review_summary()
