# Bootstrapping the PavedRoad Development Kit

## Bootstrap Scripts

In order to bootstrap the PavedRoad Development Kit
download and run one of the following scripts:

    - bootstrap-unix.sh
    - bootstrap-macos.sh

## sudo Requirement

In order to run bootstrap-unix.sh the user must have the correct sudo permission
set up to install packages.
The script checks the sudo permission for the user and prompts for a password if necessary.

In order to run bootstrap-macos.sh the user must have the correct sudo permission
set up to create directories in /usr/local and to change ownership of directories in /usr/local.
The script prompts for a sudo password if necessary.

## Unix Bootstrap

The unix bootstrap script does the following:

1) installs curl and git
2) uses curl to download salt bootstrap script
3) uses salt bootstrap script to install SaltStack
4) uses git to download the salt states
5) runs apply-state.sh to install the PavedRoad development environment

The command to download and run the bootstrap script for Unix:

curl -L https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh |
/bin/bash

## MacOS Bootstrap

The MacOS bootstrap script does the following:

1) installs the xcode development tools
2) prepares _/usr/local_ for Homebrew installation

   * later versions of MacOS do not allow the _/usr/local_ directory to be modified
   * the script creates Homebrew directories in _/usr/local_ if they do not exist
   * the script then changes the ownership of these directories to the current user
3) installs Homebrew
4) uses Homebrew to install SaltStack
5) uses git to download the salt states
6) runs apply-state.sh to install the PavedRoad development environment

The command to download and run the bootstrap script for MacOS:

curl -L https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh |
/bin/bash


