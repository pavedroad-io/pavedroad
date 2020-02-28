# {{project}} Docker Containers

This directory contains a Dockerfile for each of the platforms that the 
Unix bootstrap script has been tested to build a docker container.
For each Dockerfile a shell script is provided that runs
the docker build command.
The scripts also give examples of how options are passed to the
Unix bootstrap script.

### Platforms Tested

For detailed information on platforms that have been tested see:
[Platforms Tested]({{devkit_platforms}}).

### Bootstrap Script Detail

See more detailed information on bootstrap scripts for the {{project}}:
[Bootstrap Detail]({{devkit_bootstrap}}).

### Base Docker Images

All of the base Docker images in the Dockerfiles are pulled from this site:
[Official Docker Images](https://hub.docker.com/search?q=&type=image&image_filter=official).

Feedback is much appreciated on installing the {{project}} on other distributions,
see: [Support]({{support}}).

{% include 'readme-trailer.md' %}
