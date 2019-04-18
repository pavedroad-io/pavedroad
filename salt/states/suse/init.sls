# Install suse packages

{% set installs = grains.cfg_suse.installs %}

{% if installs and 'devtools' in installs %}
devtools:
  pkg.installed:
    - name:     patterns-devel-base-devel_rpm_build
  {% if grains.cfg_suse.devtools.version is defined %}
    - version:  {{ grains.cfg_suse.devtools.version }}
  {% endif %}
{% endif %}
