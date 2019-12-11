# Install ctags

{% set installs = grains.cfg_ctags.installs %}
{% set ctags_pkg_name = 'ctags' %}

{% if installs and 'ctags' in installs %}

ctags:
  pkg.installed:
  {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ ctags_pkg_name }}
  {% else %}
    - unless:   command -v {{ ctags_pkg_name }}
  {% endif %}
    - name:     {{ ctags_pkg_name }}
  {% if grains.cfg_ctags.ctags.version is defined %}
    - version:  {{ grains.cfg_ctags.ctags.version }}
  {% endif %}

{% endif %}

