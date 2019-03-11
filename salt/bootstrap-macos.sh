#!/bin/bash

# Bootstrap saltstack on MacOS

# Install developer tools
xcode-select --install

# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install saltstack
brew install saltstack

# Get salt states
git clone https://github.com/pavedroad-io/kevlar-repo.git

# Apply salt states
sudo kevlar-repo/salt/apply-state.sh
