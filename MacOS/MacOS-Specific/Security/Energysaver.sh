#

## Energy Saver

# Disable "Wake for network access" 

pmset -g | egrep womp  #Looking for "Womp 0"


sudo pmset -a womp 0 # Set to Womp 0

