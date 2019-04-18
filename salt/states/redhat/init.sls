# Install redhat packages

{% set installs = grains.cfg_redhat.installs %}

{% if installs and 'devtools' in installs %}
devtools:
  pkg.installed:
    - name:     Development Tools
  {% if grains.cfg_redhat.devtools.version is defined %}
    - version:  {{ grains.cfg_redhat.devtools.version }}
  {% endif %}
{% endif %}
