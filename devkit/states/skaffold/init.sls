# Install skaffold

{% set installs = grains.cfg_skaffold.installs %}
{% set completion = grains.cfg_skaffold.completion %}

{% if installs and 'skaffold' in installs %}
  {% set skaffold_pkg_name = 'skaffold' %}
  {% set skaffold_binary_install = True %}
  {% set skaffold_snap_install = False %}
  {% set skaffold_path = '/usr/local/bin/' %}

  {% if skaffold_binary_install %}
    {% if grains.cfg_skaffold.skaffold.version is defined %}
      {% set version = grains.cfg_skaffold.skaffold.version %}
    {% else %}
      {% set version = 'latest' %}
    {% endif %}
    {% set skaffold_prefix = 'https://storage.googleapis.com/skaffold/releases/' %}
    {% if grains.os_family == 'MacOS' %}
      {% set skaffold_version = version + '/skaffold-darwin-amd64' %}
    {% else %}
      {% set skaffold_version = version + '/skaffold-linux-amd64' %}
    {% endif %}
    {% set skaffold_url = skaffold_prefix + skaffold_version %}
  {% elif skaffold_snap_install %}
    {% set skaffold_path = '/snap/bin/' %}
  {% endif %}

  {% if skaffold_snap_install %}
include:
  - snapd
  {% endif %}

skaffold:
  {% if skaffold_binary_install %}
  file.managed:
    - name:     {{ skaffold_path }}skaffold
    - source:   {{ skaffold_url }}
    - makedirs: True
    - skip_verify: True
    - mode:     755
    - replace:  False
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

# brew install skaffold also installs bash completion for skaffold
# so we do not overwrite completion file

  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/skaffold' %}
skaffold-bash-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.bash }}
                {{ skaffold_path }}skaffold completion bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ skaffold_path }}skaffold
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_skaffold' %}
skaffold-zsh-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.zsh }}
                {{ skaffold_path }}skaffold completion zsh > {{ zsh_comp_file }}
    - unless:   test -e {{ zsh_comp_file }}
    - onlyif:   test -x {{ skaffold_path }}skaffold
    {% endif %}
  {% endif %}

  {% if grains.cfg_skaffold.debug.enable %}
skaffold-version:
  cmd.run:
    - name:     {{ skaffold_path }}skaffold version
  {% endif %}
{% endif %}
