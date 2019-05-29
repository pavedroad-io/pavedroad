# Install skaffold

{% set installs = grains.cfg_skaffold.installs %}

{% if installs and 'skaffold' in installs %}
  {% set skaffold_pkg_name = 'skaffold' %}
  {% set skaffold_alt_install = False %}
  {% set skaffold_snap_install = True %}
  {% set skaffold_path = '/snap/bin/' %}

  {% if grains.docker %}
    {% set skaffold_alt_install = True %}
    {% set skaffold_snap_install = False %}
  {% elif grains.os_family == 'MacOS' %}
    {% set skaffold_snap_install = False %}
  {% elif grains.os_family == 'Windows' %}
    {% set skaffold_snap_install = False %}
  {% endif %}

  {% if not skaffold_snap_install %}
    {% set skaffold_path = '' %}
  {% endif %}

  {% if skaffold_snap_install %}
include:
  - snapd
  {% endif %}

skaffold:
  {% if skaffold_alt_install %}
  {% set version = 'latest' %}
    {% if grains.cfg_skaffold.skaffold.linux_version is defined %}
      {% set version = grains.cfg_skaffold.skaffold.linux_version %}
    {% endif %}
  cmd.run:
    - unless:   command -v skaffold
    - name: |
                curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/{{ version }}/skaffold-linux-amd64
                chmod +x skaffold
                mv skaffold /usr/local/bin/skaffold
  {% elif skaffold_snap_install %}
  cmd.run:
    - require:
      - sls:    snapd
    - unless:   snap list | grep skaffold
    - name:     snap install skaffold
  {% else %}
  pkg.installed:
    - unless:   command -v skaffold
    - name:     skaffold
    {% if grains.cfg_skaffold.skaffold.version is defined %}
    - version:  {{ grains.cfg_skaffold.skaffold.version }}
    {% endif %}
  {% endif %}

  {% if grains.cfg_skaffold.debug.enable %}
skaffold-version:
  cmd.run:
    - name:     {{ skaffold_path }}skaffold version
  {% endif %}
{% endif %}
