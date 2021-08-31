# Installing the PavedRoad Development Kit

## Bootstrap Scripts

Two scripts are provided to bootstrap the PavedRoad Development Kit,
one for many Linux distributions and one for MacOS.
These scripts install SaltStack which is then run in masterless mode
to automate the installation of the PavedRoad Development Kit.

In order to run the bootstrap scripts the user must have the
correct _sudo_ privileges set up to install packages.
Each script checks the _sudo_ privileges for the user and prompts for a
password if necessary.

See more detailed information on bootstrap scripts for the Development Kit:
[Bootstrap Detail](https://github.com/pavedroad-io/pavedroad/blob/master/devkit/BOOTSTRAP.md).

## Unix Bootstrap

The Unix bootstrap script performs the following tasks:

1. Checks the user's sudo privileges
2. Installs commands required to bootstrap salt
3. Installs the SaltStack package
4. Downloads the salt states for the devkit
5. Applies salt states to bootstrap the devkit

Two methods are provided here to download and run the bootstrap script for Unix
that use either _curl_ or _wget_ to perform the download:

bash -c "$(curl -fsSL https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

bash -c "$(wget -qO- https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

If installing on a system that does not have _curl_ or _wget_ installed see:
[Installation Alternatives](#installation-alternatives)

## MacOS Bootstrap

The MacOS bootstrap script performs the following tasks:

1. Installs Homebrew with a ruby script
2. Installs the Xcode development tools
3. Installs SaltStack using Homebrew
4. Downloads the salt states for the devkit
5. Applies salt states to bootstrap the devkit

Two methods are provided here to download and run the bootstrap script for MacOS
that use either _curl_ or _wget_ to perform the download:

bash -c "$(curl -fsSL https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh)"

bash -c "$(wget -qO- https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh)"

If installing on a system that does not have _curl_ or _wget_ installed see
the next section.

### Installation Alternatives

The system package installer can be used to install _curl_ or _wget_ if
needed to run the above scripts.

Alternatively the bootstrap script can be downloaded by first going to one
of the bootstrap script pages on github by clicking on one of the following:
(1) [bootstrap-unix.sh](/devkit/bootstrap-unix.sh)
or (2) [bootstrap-macos.sh](/devkit/bootstrap-macos.sh)

Several rows of buttons will appear on the top right of the screen.
Look several rows down for a row with a *Raw* button on the left side.
Right click on the *Raw* button and select *Download Linked File*.
This will download the bootstrap script to your system.
Now enter the appropriate command below to execute the bootstrap script:

    bash bootstrap-unix.sh
    bash bootstrap-macos.sh

### Docker Support

For examples of Dockerfiles that build Docker container images
by running the Unix bootstrap script see: [Dockerfile Examples](/devkit/docker).

### Vagrant VirtualBox Support

For examples of Vagrantfiles that provision Vagrant VirtualBox images
with the Unix bootstrap script see: [Vagrantfile Examples](/devkit/vagrant).


