# Install kompose

{% set installs = grains.cfg_kompose.installs %}
{% set completion = grains.cfg_kompose.completion %}

{% if installs and 'kompose' in installs %}
  {% set kompose_pkg_name = 'kompose' %}
  {% set kompose_binary_install = True %}
  {% set kompose_path = '/usr/local/bin/' %}

  {% if kompose_binary_install %}
    {% if grains.cfg_kompose.kompose.version is defined and
      grains.cfg_kompose.kompose.version != 'latest' %}
      {% set version = grains.cfg_kompose.kompose.version %}
    {% else %}
      {% set version = salt.cmd.run('curl -s https://raw.githubusercontent.com/kubernetes/kompose/master/build/VERSION') %}
    {% endif %}
    {% set kompose_prefix = 'https://github.com/kubernetes/kompose/releases/download/' %}
    {% if grains.os_family == 'MacOS' %}
      {% set kompose_version = 'v' + version + '/kompose-darwin-amd64' %}
    {% else %}
      {% set kompose_version = 'v' + version + '/kompose-linux-amd64' %}
    {% endif %}
    {% set kompose_url = kompose_prefix + kompose_version %}
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

  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/kompose' %}
kompose-bash-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.bash }}
                {{ kompose_path }}kompose completion bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ kompose_path }}kompose
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_kompose' %}
kompose-zsh-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.zsh }}
                {{ kompose_path }}kompose completion zsh > {{ zsh_comp_file }}
    - unless:   test -e {{ zsh_comp_file }}
    - onlyif:   test -x {{ kompose_path }}kompose
    {% endif %}
  {% endif %}

  {% if grains.cfg_kompose.debug.enable %}
kompose-version:
  cmd.run:
    - name:     {{ kompose_path }}kompose version
  {% endif %}
{% endif %}
