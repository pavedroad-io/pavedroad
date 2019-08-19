# Development Kit

This project provides the tools to install a cloud native software development environment.
The development environment supports versions of the _bash_ shell and the _vim_ editor that
have been enhanced through completions and plugins to support a cloud native environment.
In addition the project installs the _go_ language and relevant packages along with
the _git_ command and other minimally needed development software.

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
SaltStack (in masterless mode) is used to install the development environment.
Thus the bootstrap script runs _salt-call_ to apply the salt states in the cloned
repository to the target device.
Running the bootstrap script installs the complete development environment.

See the information needed to perform this bootstrap: [Install](/devkit/INSTALL.md).

## Development Environment

The first release provides a bare bones environment with the following:

- Tools to enhance the usage of the bash shell
- The vim editor and tools to enhance its usage
- The go language along a number of relevant go packages
- The git command and other minimally necessary software

Future releases will add new curated software as it makes sense.

### Bash

The _bash_ shell, bash aliases and bash completions are integral parts
of any reasonable development environment.
It is assumed that bash is already installed in any Unix environment.
However it is not assumed that bash-completion is installed and it
will be installed if it is missing.
Each individual completion file will only be installed if it is missing from the
bash-completions directory.

Completion of commands is especially important in a development environment
as there are commands like _git_ that have many sub commands and options.
In addition to completion capability for development commands two sets of aliases
are installed.
One set is for the go language and the other is for the git command.

See the complete list of completions installed: [Bash Completions](/devkit/BOM_BASH_COMPS.md).

### Vim

The _vim_ editor can be enhanced to become a complete IDE in its own right.
One way this is usually accomplished is by word completion that is either based on the 
programming language of the file being edited or statistical usage of words in the file.
Another way is by adding development related shell commands that can be run
inside of vim with the output going into vim buffers.
Further these commands can be mapped to one or two keystrokes for execution.
This allows one to work without ever having to leave vim and this is what turns
vim into an IDE.
If the version of vim on the target device is not vim 8.0 or later then
the latest version of vim is installed.

See the complete list of plugins installed: [Vim Plugins](/devkit/BOM_VIM_PLUGINS.md).

### Golang

The _go_ language has become popular for developing microservices for the
cloud native environment.
Many go packages are available either as development tools or as base
libraries that can be incorporated into development projects.
Some of these go tools may have been developed as bash completions or vim plugins.
This project installs go package tools as well as completions and plugins.

See the complete list of packages installed: [Go Packages](/devkit/BOM_GO_PACKAGES.md).

### Software

One of the most important pieces of development software is the _git_ command.
Two package installers that are not fully supported by SaltStack are installed
and used by this project, _pip3_ and _snap_.
This project installs several systems for running cloud native applications
such as _docker_, _microk8s_, and _multipass_.
Other cloud native applications include _docker-compose_, _kompose_, _kubebuilder_,
_kubectl_, _kustomize_, and _skaffold_.

See the complete list of software installed: [Development Software](/devkit/BOM_DEV_SOFTWARE.md).

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

- Docker containers with Ubuntu 18.04, CentOS 7.6, and openSUSE Leap 15
- VirtualBox VMs with Ubuntu 18.04, CentOS 7.6, and openSUSE Leap 15
- MacOS 10.14

## Links to More Information

### Community Meeting
This project meets on a regular basis: [TBD Community Meeting](https://zoom.us/j/7886774843).
### Getting Help
For contact information or to report a bug see [Support](/SUPPORT.md).
### How to Contribute
For guidelines on contributions see [Contributing](/CONTRIBUTING.md).
### Code of Conduct
This project follows this [Code of Conduct](/CODE_OF_CONDUCT.md).
### License
This project is licensed under the following [License](/LICENSE).
#### Do Not Edit
This file is generated so edits made to it will be overwritten.
The source template may be edited:
[README.md](/assets/templates/devkit/README.md)

For complete instructions on editing templates and processing them see:
[Document Generation](/assets/README.md)
