# Install direnv

{% set installs = grains.cfg_direnv.installs %}

{% if installs and 'direnv' in installs %}
  {% set direnv_pkg_name = 'direnv' %}

direnv:
  {% if grains.os == 'CentOS' %}
  file.managed:
    - unless:   command -v {{ direnv_pkg_name }}
    - name:     /usr/local/bin/{{ direnv_pkg_name }}
    - source:   https://github.com/direnv/direnv/releases/download/v2.20.0/direnv.linux-386
    - makedirs: True
    - mode:     755
    - skip_verify: True
    - replace:  False
  {% else %}
  pkg.installed:
    - unless:   command -v {{ direnv_pkg_name }}
    - name:     {{ direnv_pkg_name }}
    {% if grains.cfg_direnv.direnv.version is defined %}
    - version:  {{ grains.cfg_direnv.direnv.version }}
    {% endif %}
  {% endif %}

  {% if grains.cfg_direnv.debug.enable %}
direnv-version:
  cmd.run:
    - name:     {{ direnv_pkg_name }} version
  {% endif %}

{% endif %}
