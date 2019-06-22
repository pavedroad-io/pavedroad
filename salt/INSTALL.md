# Boostrapping the PavedRoad Deveopment Kit

In order to bootstrap the PR dev environemt run one of the following scripts:

bootstrap-unix.sh
bootstrap-macos.sh

The unix bootstrap script does the following:

1) installs curl and git
2) uses curl to download salt bootstrap script
3) uses salt bootstrap script to install saltstack
4) uses git to downlaod the salt states
5) runs apply-state.sh to install the PR dev enviroment

The macOS bootstrap script does the following:

1) installs the xcode dev tools
2) prepares /usr/local for homebrew installation
   later versions of macOS do not allow /usr/local itself to be modified
   the script creates homebrew directories in /usr/local if they do not exist
   the script then changes the ownership of these directories to the current user
   the user must be in the /etc/sudoers file to execute these commands
3) installs homebrew
4) uses homebrew to install saltstack
5) uses git to downlaod the salt states
6) runs apply-state.sh to install the PR dev enviroment

### Do Not Edit
This file is generated so do not edit it directly.
Template files for this documentation may be edited.

[Edit the template file here.](/repo-templates/salt/INSTALL.md)
[See build instructions here.](/assets/README.md)
