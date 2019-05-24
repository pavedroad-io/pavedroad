# Install redhat packages

{% set installs = grains.cfg_redhat.installs %}

{% if installs and 'devtools' in installs %}
Development Tools:
  pkg.group_installed
epel-release:
  pkg.installed
{% endif %}
