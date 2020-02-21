# Bootstrapping the {{organization}} {{project}}

## Bootstrap Scripts

Two scripts are provided to bootstrap the {{organization}} {{project}},
one for many Linux distributions and one for MacOS.
These scripts install SaltStack which is then run in masterless mode
to automate the installation of the {{organization}} {{project}}.

In order to run the bootstrap scripts the user must have the correct sudo permission
set up to install packages.
Each script checks the sudo permission for the user and prompts for a
password if necessary.

See more detailed information on bootstrap scripts for the {{project}}:
[Install Detail]({{devkit_install_detail}}).

## Unix Bootstrap

The unix bootstrap script does the following:

1) checks the user's sudo permission
2) installs commands required to bootstrap salt
3) runs those commands to install salt
4) downloads the salt states for the devkit
5) runs salt to bootstrap the devkit

Two methods are provided to download and run the bootstrap script for Unix
that use either curl or wget to perform the download :

bash -c "$(curl -fsSL https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

bash -c "$(wget -q0 https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

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

bash -c "$(wget -q0 https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh)"

{% include 'footer.md' %}
