# Install skaffold

{% set installs = grains.cfg_skaffold.installs %}

{% if installs and 'skaffold' in installs %}
  {% set skaffold_pkg_name = 'skaffold' %}
  {% set skaffold_linux_install = True %}

  {% if grains.os_family == 'MacOS' %}
    {% set skaffold_linux_install = False %}
  {% elif grains.os_family == 'Windows' %}
    {% set skaffold_linux_install = False %}
  {% endif %}

skaffold:
  {% if skaffold_linux_install %}
  {% set version = 'latest' %}
    {% if grains.cfg_skaffold.skaffold.linux_version is defined %}
      {% set version = grains.cfg_skaffold.skaffold.linux_version %}
    {% endif %}
  cmd.run:
    - name: |
                curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/{{ version }}/skaffold-linux-amd64
                chmod +x skaffold
                $(command -v sudo) mv skaffold /usr/local/bin/skaffold
  {% else %}
  pkg.installed:
    - name:     skaffold
    {% if grains.cfg_skaffold.skaffold.version is defined %}
    - version:  {{ grains.cfg_skaffold.skaffold.version }}
    {% endif %}
  {% endif %}
{% endif %}
