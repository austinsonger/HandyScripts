# Require API Key to run

readApiKey() {
echo -n "Enter your API Key: "
        read apiKey;
if [ -z "$apiKey" ]
        then
                echo "Input cannot be null"; readApiKey;
        else apiCall;
fi
}

# API call example
apiCall() { 

curl \
  -X 'POST' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  -d '{ "filter" : [{ "hostname" : { "$regex" : "^cent" }}]}' \
  "https://console.jumpcloud.com/api/search/systems"

}

readApiKey
