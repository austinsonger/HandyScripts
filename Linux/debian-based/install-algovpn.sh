sudo apt update -y && sudo apt upgrade -y
sudo apt install -y python3-virtualenv
git clone https://github.com/trailofbits/algo.git
cd algo

## Install ALGO Env.
python3 -m virtualenv --python="$(command -v python3)" .env &&
  source .env/bin/activate &&
  python3 -m pip install -U pip virtualenv &&
  python3 -m pip install -r requirements.txt