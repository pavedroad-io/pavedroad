# Bootstrapping the {{organization}} {{project}}

In order to bootstrap the {{organization}} development environment
run one of the following scripts:

    bootstrap-unix.sh
    bootstrap-macos.sh

The unix bootstrap script does the following:

1) installs curl and git
2) uses curl to download salt bootstrap script
3) uses salt bootstrap script to install SaltStack
4) uses git to download the salt states
5) runs apply-state.sh to install the {{organization}} development environment

The MacOS bootstrap script does the following:

1) installs the xcode development tools
2) prepares _/usr/local_ for Homebrew installation

   * later versions of MacOS do not allow _/usr/local_ itself to be modified
   * the script creates Homebrew directories in _/usr/local_ if they do not exist
   * the script then changes the ownership of these directories to the current user
   * the user must be in the _/etc/sudoers_ file to execute these commands
3) installs Homebrew
4) uses Homebrew to install SaltStack
5) uses git to download the salt states
6) runs apply-state.sh to install the {{organization}} development environment

{% include 'do-not-edit.md' %}
