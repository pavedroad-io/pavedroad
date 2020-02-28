# {{project}} Vagrant VirtualBox VMs

This directory contains a subdirectory for each of the platforms that the 
Unix bootstrap script has been tested in a Vagrant VirtualBox VM.
Each subdirectory contains a Vagrantfile for each of the platforms that the 
Unix bootstrap script has been tested in a VirtualBox VM.
In addition to the Vagrantfile in each subdirectory a shell script
is provided that runs the "vagrant up" command.
These scripts also provide examples of how options are passed to the
Unix bootstrap script.

### Platforms Tested

For detailed information on platforms that have been tested see:
[Platforms Tested]({{devkit_platforms}}).

### Bootstrap Script Detail

See more detailed information on bootstrap scripts for the {{project}}:
[Bootstrap Detail]({{devkit_bootstrap}}).

### Vagrant VirtualBox Boxes

All of the Vagrant VirtualBox images in the Vagrantfiles are pulled from this site:
See [Vagrant Box Catalog](https://app.vagrantup.com/boxes/search).

Feedback is much appreciated on installing the {{project}} on other distributions,
see: [Support]({{support}}).

{% include 'readme-trailer.md' %}
