# Install kompose

{% set installs = grains.cfg_kompose.installs %}

{% if installs and 'kompose' in installs %}
  {% set kompose_pkg_name = 'kompose' %}
  {% set kompose_linux_install = True %}
  {% set kompose_path = '/usr/local/bin/' %}

  {% if grains.os_family == 'MacOS' %}
    {% set kompose_linux_install = False %}
  {% elif grains.os_family == 'Windows' %}
    {% set kompose_linux_install = False %}
  {% endif %}

  {% if not kompose_linux_install %}
    {% set kompose_path = '' %}
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
                mv kompose {{ kompose_path }}kompose
  {% else %}
  pkg.installed:
    - unless:   command -v kompose
    - name:     kompose
    {% if grains.cfg_kompose.kompose.version is defined %}
    - version:  {{ grains.cfg_kompose.kompose.version }}
    {% endif %}
  {% endif %}

  {% if grains.cfg_kompose.debug.enable %}
kompose-version:
  cmd.run:
    - name:     {{ kompose_path }}kompose version
  {% endif %}
{% endif %}
