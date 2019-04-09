#!/bin/bash

# Bootstrap saltstack on MacOS

# Install developer tools
xcode-select --install

# Prepare /usr/local for homebrew
brewdirs=(Caskroom Cellar Frameworks Homebrew bin doc etc include lib libexec opt sbin share var)
cd /usr/local
sudo mkdir -p -m 0755 ${brewdirs}
sudo chown -R $(whoami) ${brewdirs}
cd

# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install saltstack
brew install saltstack

# Get salt states
git clone https://github.com/pavedroad-io/kevlar-repo.git

# Apply salt states
kevlar-repo/salt/apply-state.sh
