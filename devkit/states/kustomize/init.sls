# Install kustomize

{% set installs = grains.cfg_kustomize.installs %}

{% if installs and 'kustomize' in installs %}
  {% set kustomize_pkg_name = 'kustomize' %}
  {% set kustomize_binary_install = True %}
  {% set kustomize_path = '/usr/local/bin/' %}

  {% if kustomize_binary_install %}
    {% if grains.cfg_kustomize.kustomize.version is defined %}
      {% set version = grains.cfg_kustomize.kustomize.version %}
    {% else %}
      {% set version = 'latest' %}
    {% endif %}
    {% set kustomize_prefix = 'https://github.com/kubernetes-sigs/kustomize/releases/download/' %}
    {% if grains.os_family == 'MacOS' %}
      {% set kustomize_version = 'v' + version + '/kustomize_' + version + '_darwin_amd64' %}
    {% else %}
      {% set kustomize_version = 'v' + version + '/kustomize_' + version + '_linux_amd64' %}
    {% endif %}
    {% set kustomize_url = kustomize_prefix + kustomize_version %}
  {% endif %}

kustomize:
  {% if kustomize_binary_install %}
  file.managed:
    - name:     {{ kustomize_path }}kustomize
    - source:   {{ kustomize_url }}
    - makedirs: True
    - skip_verify: True
    - mode:     755
    - replace:  False
  {% else %}
  pkg.installed:
    - unless:   command -v kustomize
    - name:     kustomize
    {% if grains.cfg_kustomize.kustomize.version is defined %}
    - version:  {{ grains.cfg_kustomize.kustomize.version }}
    {% endif %}
  {% endif %}

  {% if grains.cfg_kustomize.debug.enable %}
kustomize-version:
  cmd.run:
    - name:     {{ kustomize_path }}kustomize version
  {% endif %}
{% endif %}
