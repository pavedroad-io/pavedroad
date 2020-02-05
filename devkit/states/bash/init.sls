# Install bash-completion and copy and source bash config files

{% set installs = grains.cfg_bash.installs %}
{% set packages = grains.cfg_bash.packages %}
{% set files = grains.cfg_bash.files %}
{% set bash_pkg_name = 'bash' %}

{% if installs and 'bash' in installs %}
bash:
  pkg.installed:
  {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ bash_pkg_name }}
  {% else %}
    - unless:   command -v {{ bash_pkg_name }}
  {% endif %}
    - name:     {{ bash_pkg_name }}
  {% if grains.cfg_bash.bash.version is defined %}
    - version:  {{ grains.cfg_bash.bash.version }}
  {% endif %}

{# Make sure bash config files are not owned by root if created here #}
bashrc:
  file.managed:
    - name:     {{ grains.homedir }}/.bashrc
    - replace:  False
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
{# Location where pavedroad installs local bash completion files #}
bash_completion_dir:
  file.directory:
    - name:     {{ pillar.directories.completions.bash }}
    - makedirs: True
    - mode:     755
{% endif %}

{% if packages and 'bash-completion' in packages %}
bash_completion:
  pkg.installed:
    - name:     bash-completion
  {% if grains.os_family == 'MacOS' %}
    - unless:   |
                brew list bash-completion
                brew list bash-completion@2
  {% endif %}
{% endif %}

{% if files and 'completion' in files %}
bash-pr_completion:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bash_completion
    - source:   salt://bash/pr_bash_completion
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
{% endif %}

{% if files and 'bashrc' in files %}
pr_bashrc:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - source:   salt://bash/pr_bashrc
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if files and 'completion' in files and grains.cfg_bash.completion.append %}
  {% set grub_comp_file = '/etc/bash_completion.d/grub' %}
  {% set comp_old_dir = '/etc/bash_completion_old.d' %}
pr_bash_completion:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     source $HOME/.pr_bash_completion
    - require:
      - file:   bash-pr_completion
      - file:   pr_bashrc
  {# bash_completion fails on grub on some systems so it is moved out #}
  cmd.run:
    - onlyif:   test -e {{ grub_comp_file }}
    - name:     |
                mkdir -p {{ comp_old_dir }}
                mv {{ grub_comp_file }} {{ comp_old_dir }}
  {% endif %}

  {% if grains.cfg_bash.bashrc.append %}
append_source-bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.bashrc
    - text:     source $HOME/.pr_bashrc
    - require:
      - file:   bashrc
      - file:   pr_bashrc
  {% endif %}
  {% if grains.cfg_bash.debug.enable %}
bash-version:
  cmd.run:
    - name:     {{ bash_pkg_name }} --version
  {% endif %}
{% endif %}
