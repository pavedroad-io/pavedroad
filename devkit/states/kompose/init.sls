# Install kompose

{% set installs = grains.cfg_kompose.installs %}
{% set completion = grains.cfg_kompose.completion %}

{% if installs and 'kompose' in installs %}
  {% set kompose_pkg_name = 'kompose' %}
  {% set kompose_binary_install = True %}
  {% set kompose_path = '/usr/local/bin/' %}

  {% if kompose_binary_install %}
    {% set kompose_prefix = 'https://github.com/kubernetes/kompose/releases/download/' %}
    {% set version = 'v1.18.0' %}
    {% if grains.os_family == 'MacOS' %}
      {% set kompose_version = version + '/kompose-darwin-amd64' %}
    {% else %}
      {% set kompose_version = version + '/kompose-linux-amd64' %}
    {% endif %}
    {% set kompose_url = kompose_prefix + '/' + kompose_version %}
  {% endif %}

  {% if completion and 'bash' in completion %}
include:
  - bash
  {% endif %}

kompose:
  {% if kompose_binary_install %}
  file.managed:
    - name:     {{ kompose_path }}kompose
    - source:   {{ kompose_url }}
    - makedirs: True
    - skip_verify: True
    - mode:     755
    - replace:  False
  {% else %}
  pkg.installed:
    - unless:   command -v kompose
    - name:     kompose
    {% if grains.cfg_kompose.kompose.version is defined %}
    - version:  {{ grains.cfg_kompose.kompose.version }}
    {% endif %}
  {% endif %}

# brew install kompose also installs bash completion for kompose
# so we do not overwrite completion file

  {% if completion and 'bash' in completion %}
    {% if grains.os_family == 'MacOS' %}
      {% set bash_comp_dir = '/usr/local/etc/bash_completion.d/' %}
    {% else %}
      {% set bash_comp_dir = '/usr/share/bash-completion/completions/' %}
    {% endif %}
    {% set bash_comp_file = bash_comp_dir + 'kompose' %}
kompose-bash-completion:
  cmd.run:
    - name:     {{ kompose_path }}kompose completion bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ kompose_path }}kompose
    - require:
      - sls:    bash
  {% endif %}

  {% if grains.cfg_kompose.debug.enable %}
kompose-version:
  cmd.run:
    - name:     {{ kompose_path }}kompose version
  {% endif %}
{% endif %}
