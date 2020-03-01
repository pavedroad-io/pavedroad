# Installing the {{organization}} {{project}}

## Bootstrap Scripts

Two scripts are provided to bootstrap the {{organization}} {{project}},
one for many Linux distributions and one for MacOS.
These scripts install SaltStack which is then run in masterless mode
to automate the installation of the {{organization}} {{project}}.

In order to run the bootstrap scripts the user must have the
correct _sudo_ privileges set up to install packages.
Each script checks the _sudo_ privileges for the user and prompts for a
password if necessary.

See more detailed information on bootstrap scripts for the {{project}}:
[Bootstrap Detail]({{devkit_bootstrap}}).

## Unix Bootstrap

The Unix bootstrap script performs the following tasks:

1. Checks the user's sudo privileges
2. Installs commands required to bootstrap salt
3. Installs the SaltStack package
4. Downloads the salt states for the devkit
5. Applies salt states to bootstrap the devkit

Two methods are provided to download and run the bootstrap script for Unix
that use either curl or wget to perform the download :

bash -c "$(curl -fsSL https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

bash -c "$(wget -qO- https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-unix.sh)"

## MacOS Bootstrap

The MacOS bootstrap script performs the following tasks:

1. Installs Homebrew with a ruby script
2. Installs the Xcode development tools
3. Installs SaltStack using Homebrew
4. Downloads the salt states for the devkit
5. Applies salt states to bootstrap the devkit

Two methods are provided to download and run the bootstrap script for MacOS
that use either curl or wget to perform the download :

bash -c "$(curl -fsSL https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh)"

bash -c "$(wget -qO- https://raw.githubusercontent.com/pavedroad-io/pavedroad/master/devkit/bootstrap-macos.sh)"

### Installation Alternative

Alternatively a bootstrap script can be downloaded and saved by executing the
_curl_ or _wget_ command and then running the script as the second step.

### Docker Support

For examples of Dockerfiles that build Docker container images
by running the Unix bootstrap see: [Dockerfile Examples]({{docker_readme}}).

### Vagrant VirtualBox Support

For examples of Vagrantfiles that provision Vagrant VirtualBox images
with the Unix bootstrap see: [Vagrantfile Examples]({{vagrant_readme}}).

{% include 'footer.md' %}
