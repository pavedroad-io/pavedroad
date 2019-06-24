# Install redhat packages

{% set installs = grains.cfg_redhat.installs %}

{% if installs and 'devtools' in installs %}

Development Tools:
  pkg.group_installed
  {% if not grains.os == 'Fedora' %}
epel-release:
  pkg.installed
  {% endif %}
{% endif %}
