INSTALL.md

In order to bootstrap the PR dev environemt run the following script:

bootstrap-macos.sh

The bootstrap script does the following:

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
