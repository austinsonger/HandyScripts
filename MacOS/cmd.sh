#generate your key
ssh-keygen -t rsa 4096 -C "charon@prevailhealth.com"

eval "$(ssh-agent -s)"

# add to the macos keychain
ssh-add -K ~/.ssh/id_rsa

