# Bootstrapping the PavedRoad Development Kit

## Bootstrap Scripts

Two scripts are provided to bootstrap the PavedRoad Development Kit,
one for many Linux distributions and one for MacOS.
These scripts install SaltStack which is then run in masterless mode
to automate the installation of the PavedRoad Development Kit.

In order to run the bootstrap scripts the user must have the correct _sudo_ privileges
set up to install packages.
Each script checks the _sudo_ privileges for the user and prompts for a
password if necessary.

See more detailed information on bootstrap scripts for the Development Kit:
[Bootstrap Detail](/devkit/BOOTSTRAP.md).

## Unix Bootstrap

The unix bootstrap script does the following:

1) checks the user's sudo privileges
2) installs commands required to bootstrap salt
3) runs those commands to install salt
4) downloads the salt states for the devkit
5) runs salt to bootstrap the devkit

Two methods are provided to download and run the bootstrap script for Unix
that use either curl or wget to perform the download :

bash -c "$(curl -fsSL https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

bash -c "$(wget -qO- https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

## MacOS Bootstrap

The MacOS bootstrap script does the following:

1) installs the xcode development tools
2) runs a script to install Homebrew
3) uses Homebrew to install salt
4) downloads the salt states for the devkit
5) runs salt to bootstrap the devkit

Two methods are provided to download and run the bootstrap script for MacOS
that use either curl or wget to perform the download :

bash -c "$(curl -fsSL https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh)"

bash -c "$(wget -qO- https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh)"

### Docker Support

For docker examples of containers initializes with the Unix bootstrap see:
[Dockerfile Examples](/devkit/docker/README.md).

### Vagrant VirtualBox Support

For docker examples of containers initializes with the Unix bootstrap see:
[Vagrantfile Examples](/devkit/vagrant/README.md).


