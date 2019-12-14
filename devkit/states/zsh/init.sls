# Install zsh

{% set installs = grains.cfg_zsh.installs %}
{% set packages = grains.cfg_zsh.packages %}
{% set files = grains.cfg_zsh.files %}
{% set zsh_pkg_name = 'zsh' %}

{% if installs and 'zsh' in installs %}
zsh:
  pkg.installed:
  {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ zsh_pkg_name }}
  {% else %}
    - unless:   command -v {{ zsh_pkg_name }}
  {% endif %}
    - name:     {{ zsh_pkg_name }}
  {% if grains.cfg_zsh.zsh.version is defined %}
    - version:  {{ grains.cfg_zsh.zsh.version }}
  {% endif %}
  file.directory:
    - name:     {{ pillar.directories.completions.zsh }}
    - makedirs: True
    - mode:     755
{% endif %}

# Unlike bash, zsh completions are installed along with zsh
# zsh-completions below are extra completions not yet in zsh repo
{% if packages and 'completion' in packages %}
completion:
  {% if grains.os_family == 'MacOS' %}
  pkg.installed:
    - name:     zsh-completions
    - unless:   brew list zsh-completions
  {% else %}
  git.latest:
    - name:        https://github.com/zsh-users/zsh-completions.git
    - branch:      master
    - target:      /tmp/zsh-completions
    - force_clone: True
  file.copy:
    - name:     /usr/local/share/zsh-completions
    - source:   /tmp/zsh-completions/src
    - replace:  True
  {% endif %}
  {% if grains.cfg_zsh.debug.enable %}
zsh-version:
  cmd.run:
    - name:     {{ zsh_pkg_name }} --version
  {% endif %}
{% endif %}
