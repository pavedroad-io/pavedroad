#!/bin/bash

# Bootstrap saltstack on Unix

# Install missing developer tools
# Assuming wget or curl are installed

# Install saltstack
# wget -O install_salt.sh https://bootstrap.saltstack.com
curl -o install_salt.sh -L https://bootstrap.saltstack.com
# Prevent failure with -P flag so that the script can use pip as a dependency source
sudo sh install_salt.sh -P

# Get salt states
git clone https://github.com/pavedroad-io/kevlar-repo.git

# Apply salt states
kevlar-repo/salt/apply-state.sh
