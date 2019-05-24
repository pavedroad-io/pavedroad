# Install kompose

{% set installs = grains.cfg_kompose.installs %}

{% if installs and 'kompose' in installs %}
  {% set kompose_pkg_name = 'kompose' %}
  {% set kompose_linux_install = True %}

  {% if grains.os_family == 'MacOS' %}
    {% set kompose_linux_install = False %}
  {% elif grains.os_family == 'Windows' %}
    {% set kompose_linux_install = False %}
  {% endif %}

kompose:
  {% if kompose_linux_install %}
    {% set version = 'v1.18.0' %}
    {% if grains.cfg_kompose.kompose.linux_version is defined %}
      {% set version = grains.cfg_kompose.kompose.linux_version %}
    {% endif %}
  cmd.run:
    - unless:   command -v kompose
    - name: |
                curl -Lo kompose https://github.com/kubernetes/kompose/releases/download/{{ version }}/kompose-linux-amd64
                chmod +x kompose
                $(command -v sudo) mv kompose /usr/local/bin/kompose
  {% else %}
  pkg.installed:
    - unless:   command -v kompose
    - name:     kompose
    {% if grains.cfg_kompose.kompose.version is defined %}
    - version:  {{ grains.cfg_kompose.kompose.version }}
    {% endif %}
  {% endif %}
{% endif %}
