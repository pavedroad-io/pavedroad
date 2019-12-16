# Install kustomize

{% set installs = grains.cfg_kustomize.installs %}
{% set completion = grains.cfg_kustomize.completion %}

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

  {% if completion %}
    {# Cannot find bash completion #}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_kustomize' %}
kustomize-zsh-completion:
  file.managed:
    - name:     {{ zsh_comp_file }}
    - source:   https://raw.githubusercontent.com/zchee/zsh-completions/master/src/go/_kustomize
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
  {% endif %}

  {% if grains.cfg_kustomize.debug.enable %}
kustomize-version:
  cmd.run:
    - name:     {{ kustomize_path }}kustomize version
  {% endif %}
{% endif %}
