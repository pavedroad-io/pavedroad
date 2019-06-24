# Install skaffold

{% set installs = grains.cfg_skaffold.installs %}
{% set completion = grains.cfg_skaffold.completion %}

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
    {% set skaffold_path = '/usr/local/bin/' %}
  {% endif %}

  {% if skaffold_snap_install or completion and 'bash' in completion %}
include:
    {% if skaffold_snap_install %}
  - snapd
    {% endif %}
    {% if completion and 'bash' in completion %}
  - bash
    {% endif %}
  {% endif %}

skaffold:
  {% if skaffold_alt_install %}
    {% set version = 'latest' %}
    {% if grains.cfg_skaffold.skaffold.version is defined %}
      {% set version = grains.cfg_skaffold.skaffold.version %}
    {% endif %}
    {% set skaffold_prefix = 'https://storage.googleapis.com/skaffold/releases' %}
    {% set skaffold_version = version + '/skaffold-linux-amd64' %}
    {% set skaffold_url = skaffold_prefix + '/' + skaffold_version %}
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

  {% if completion and 'bash' in completion %}
    {% if not grains.os_family == 'MacOS' %}
      {% set bash_comp_dir = '/usr/share/bash-completion/completions/' %}
      {% set bash_comp_file = bash_comp_dir + 'skaffold' %}
skaffold-bash-completion:
  cmd.run:
    - name:     {{ skaffold_path }}skaffold completion bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ skaffold_path }}skaffold
    - require:
      - sls:    bash
    {% endif %}
  {% endif %}

  {% if grains.cfg_skaffold.debug.enable %}
skaffold-version:
  cmd.run:
    - name:     {{ skaffold_path }}skaffold version
  {% endif %}
{% endif %}
