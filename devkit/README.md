# Development Kit

This project provides the tools to install a cloud native software development environment.
The development environment supports versions of the _bash_ shell and the _vim_ editor that
have been enhanced through completions and plugins to support a cloud native environment.
In addition the project installs the _go_ language and relevant packages along with
the _git_ command and other necessary development software.

## Features

These are the core features of the Development Kit:

- It can be bootstrapped by downloading a single shell script and running it
- It supports most Linux environments and MacOS
- It runs on bare metal, on laptops, in a container or in a virtual machine

## Getting Started

A bash bootstrap script must be downloaded to the target device
and run to install the Development Kit.
This script first installs _curl_, _git_ and _salt_ on the target device and then
clones the PavedRoad Development Kit repository.

See the information needed to perform this bootstrap: [Install](https://github.com/pavedroad-io/pavedroad/blob/master/devkit/INSTALL.md).

## SaltStack

SaltStack (in masterless mode) is used to install the development environment.
Thus the bootstrap script runs _salt-call_ to apply the salt states in the cloned
repository to the target device.
Running the bootstrap script installs the complete development environment.
The salt states generally use the local package manager to do the installations.
In some cases a binary install is required in order to get a later version.
Also a build from source is required for _vim_ to set the build options.

## Development Environment

This release provides a modest development environment with the following:

- Tools to enhance the usage of the bash shell
- The zsh shell and tools as an alternative to bash
- The vim editor and tools to enhance its usage
- The go language along a number of relevant go packages
- The git command and other necessary development software

Future releases will add new curated software as it makes sense.

### Bash

The _bash_ shell, bash aliases and bash completions are integral parts
of any reasonable development environment.
It is assumed that _bash_ is already installed on most Unix systems.
However on some systems an alternative version of _bash_ may be installed
in _/usr/local/bin_.

### Zsh

The _zsh_ shell is a popular alternative to the _bash_ shell.
It is assumed that _zsh_ is not installed by default on most Unix systems
and it will be installed as part of the Development Kit
using the local system package manager.
On some systems where _zsh_ is already installed then the latest version
of _zsh_ may be installed in _/usr/local/bin_.

### Shell Completion

Completion of commands is especially important in a development environment
as there are commands like _git_ that have many sub commands and options.

It is not assumed that the _bash-completion_ package is installed so it
will be installed if it is missing.
Completions are installed for _zsh_ as part of the _zsh_ package.
Two additional packages of _zsh_ completions are installed.
Some command packages install their own completion files.
If no completion files are installed by default for specific commands
then individual completion files will be installed if they can be found.

Extra completion packages and individual completion files are installed
in two separate directories for _bash_ and _zsh_ in _/usr/local/share_.
See information on where completions are installed, how they are initialized, and
the complete list of completions installed: [Shell Completions](https://github.com/pavedroad-io/pavedroad/blob/master/devkit/BOM_SHELL_COMPS.md).

### Vim

The _vim_ editor can be enhanced to become a complete IDE in its own right.
This is accomplished by installing vim plugins.
Plugins can provide word completion that is either based on the 
programming language of the file being edited or statistical usage of words in the file.
Plugins can add development related shell commands that can be run from
inside of vim with the output going into vim buffers.
Plugins can also open extra windows with more capabilities such as directory
traversal, showing project tags, and project wide search and replace.

Further these plugin commands can be mapped to one or two keystrokes for execution.
This allows one to work without ever having to leave _vim_ and this is what turns
_vim_ into an IDE.
If the version of _vim_ on the target device is not 8.0 or later then
the latest version of _vim_ is built and installed.

See the complete list of plugins installed: [Vim Plugins](https://github.com/pavedroad-io/pavedroad/blob/master/devkit/BOM_VIM_PLUGINS.md).

### Golang

The _go_ language has become popular for developing microservices for the
cloud native environment.
Many go packages are available either as development tools or as base
libraries that can be incorporated into development projects.
Some of these go tools may have been developed as shell completions or vim plugins.
This project installs go package tools as well as completions and plugins.
Shell aliases are also installed for _golang_.

See the complete list of packages installed: [Go Packages](https://github.com/pavedroad-io/pavedroad/blob/master/devkit/BOM_GO_PACKAGES.md).

### Git

One of the most important pieces of development software is the _git_ system.
The _git_ system has been enhanced by installing shell completions and vim plugins.
Shell aliases are installed for _git_ as well as a shell prompt with _git_ features.
The _git_ prompt is set up for both _bash_ and _zsh_ with three sections:
the user@host, the current directory, and the git branch.
The prompt is set up for both _bash_ and _zsh_ with green, blue and yellow
colors respectively for the above three sections.

### Software

Two package installers that are not fully supported by SaltStack are installed
and used by this project, _pip3_ and _snap_.
This project installs several systems for running cloud native applications
such as _docker_, _microk8s_, and _multipass_.
Installed cloud native applications include _docker-compose_, _kompose_, _kubebuilder_,
_kubectl_, _kustomize_, _skaffold_, _stern_ and _tilt_.
Other development applications include _ctags_, _direnv_, _fossa-cli_, _fzf_, _graphviz_,
_jq_, _nodejs_, _ripgrep_, and _sonar-scanner_.

See the complete list of software installed: [Development Software](https://github.com/pavedroad-io/pavedroad/blob/master/devkit/BOM_DEV_SOFTWARE.md).

## Swagger

In addition to the cloud native software the Development Kit includes the ability to create
Swagger 2.0 REST API specifications and to generate golang client and server code.
This is accomplished by installing the go package _go-swagger_ and the 
UI application _pretty-swag_.
The _go-swagger_ package is an implementation of Swagger 2.0 that is specific to golang
and is more versatile than _swagger-codegen_.
The _pretty-swag_ application generates HTML from Swagger specifications and has
extensive configuration ability to provide customized output.

## Platforms Supported

### Platforms That Should Work
- Ubuntu LTS releases starting with version 16.04
- Ubuntu supported interim releases
- CentOS releases starting with version 7
- Fedora releases starting with version 29
- MacOS releases starting with version 10.13
- openSUSE Leap releases starting with version 15.0

### Platforms Tested

For detailed information on platforms that have been tested see:
[Platforms Tested](https://github.com/pavedroad-io/pavedroad/blob/master/devkit/PLATFORMS.md).

Feedback is much appreciated on installing the Development Kit on other distributions,
see: [Support](https://github.com/pavedroad-io/pavedroad/blob/master/SUPPORT.md).

## Links to More Information

### Getting Help
For contact information or to report a bug see [Support](https://github.com/pavedroad-io/pavedroad/blob/master/SUPPORT.md).
### How to Contribute
For guidelines on contributions see [Contributing](https://github.com/pavedroad-io/pavedroad/blob/master/CONTRIBUTING.md).
### Code of Conduct
This project follows this [Code of Conduct](https://github.com/pavedroad-io/pavedroad/blob/master/CODE_OF_CONDUCT.md).
### License
This project is licensed under the following [License](https://github.com/pavedroad-io/pavedroad/blob/master/LICENSE).

