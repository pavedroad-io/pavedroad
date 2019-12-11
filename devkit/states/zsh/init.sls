# Install zsh

{% set installs = grains.cfg_zsh.installs %}
{% set zsh_pkg_name = 'zsh' %}

{% if installs and 'zsh' in installs %}

zsh:
  pkg.installed:
  {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ zsh_pkg_name }}
  {% else %}
    - unless:   command -v {{ zsh_pkg_name }}
  {% endif %}
    - name:     {{ zsh_pkg_name }}
  {% if grains.cfg_zsh.zsh.version is defined %}
    - version:  {{ grains.cfg_zsh.zsh.version }}
  {% endif %}

{% endif %}

