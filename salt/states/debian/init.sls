# Install debian packages

{% set installs = grains.cfg_debian.installs %}

{% if installs and 'devtools' in installs %}
devtools:
  pkg.installed:
    - name:     build-essential
  {% if grains.cfg_debian.devtools.version is defined %}
    - version:  {{ grains.cfg_debian.devtools.version }}
  {% endif %}
{% endif %}
