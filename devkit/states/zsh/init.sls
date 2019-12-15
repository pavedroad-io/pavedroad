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

{# Make sure zsh config files are not owned by root if created here #}
zshrc:
  file.managed:
    - name:     {{ grains.homedir }}/.zshrc
    - replace:  False
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644

{# Location where pavedroad installs local zsh completion files #}
completion_dir:
  file.directory:
    - name:     {{ pillar.directories.completions.zsh }}
    - makedirs: True
    - mode:     755
{% endif %}

# Unlike bash, zsh completions are part of the zsh package install
# zsh-completions here are extra completions not yet in the zsh package
{% if packages and 'zsh-completions' in packages %}
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

{% if files and 'completion' in files %}
pr_completion:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_zsh_completion
    - source:   salt://zsh/pr_zsh_completion
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
{% endif %}

{% if files and 'zshrc' in files %}
pr_zshrc:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - source:   salt://zsh/pr_zshrc
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if files and 'completion' in files and grains.cfg_zsh.completion.append %}
append-source-completion:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     source $HOME/.pr_zsh_completion
    - require:
      - file:   pr_completion
      - file:   pr_zshrc
  {% endif %}

  {% if grains.cfg_zsh.zshrc.append %}
append_source-zshrc:
  file.append:
    - name:     {{ grains.homedir }}/.zshrc
    - text:     source $HOME/.pr_zshrc
    - require:
      - file:   zshrc
  {% endif %}
{% endif %}
