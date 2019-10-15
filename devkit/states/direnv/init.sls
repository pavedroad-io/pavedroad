# Install direnv

{% set installs = grains.cfg_direnv.installs %}

{% if installs and 'direnv' in installs %}
  {% set direnv_pkg_name = 'direnv' %}

direnv:
  pkg.installed:
    - unless:   command -v {{ direnv_pkg_name }}
    - name:     {{ direnv_pkg_name }}
  {% if grains.cfg_direnv.direnv.version is defined %}
    - version:  {{ grains.cfg_direnv.direnv.version }}
  {% endif %}

{% endif %}
