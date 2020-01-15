# Install fzf

{% set installs = grains.cfg_fzf.installs %}
{% set completion = grains.cfg_fzf.completion %}
{% set fzf_pkg_name = 'fzf' %}

{% if installs and 'fzf' in installs %}

fzf:
  pkg.installed:
  {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ fzf_pkg_name }}
  {% else %}
    - unless:   command -v {{ fzf_pkg_name }}
  {% endif %}
    - name:     {{ fzf_pkg_name }}
  {% if grains.cfg_fzf.fzf.version is defined %}
    - version:  {{ grains.cfg_fzf.fzf.version }}
  {% endif %}
  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/fzf' %}
fzf-bash-completion:
  file.managed:
    - name:     {{ bash_comp_file }}
    - source:   https://github.com/junegunn/fzf/blob/master/shell/completion.bash
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_fzf' %}
fzf-zsh-completion:
  file.managed:
    - name:     {{ zsh_comp_file }}
    - source:   https://github.com/junegunn/fzf/blob/master/shell/completion.zsh
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
  {% endif %}

  {% if grains.cfg_fzf.debug.enable %}
fzf-version:
  cmd.run:
    - name:     {{ fzf_pkg_name }} --version
  {% endif %}
{% endif %}

