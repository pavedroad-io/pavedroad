# Install bash-completion and copy and source bash config files

{% set packages = grains.cfg_bash.packages %}
{% set files = grains.cfg_bash.files %}

{% if packages and 'completion' in packages %}
completion:
  pkg.installed:
    - name:     bash-completion
  {% if grains.os_family == 'MacOS' %}
    - unless:   |
                brew list bash-completion
                brew list bash-completion@2
  {% endif %}
{% endif %}

{# Make sure bash config files are not owned by root if created here #}
bashrc:
  file.managed:
    - name:     {{ grains.homedir }}/.bashrc
    - replace:  False
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
bash_profile:
  file.managed:
    - name:     {{ grains.homedir }}/.bash_profile
    - replace:  False
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644

{% if files and 'completion' in files %}
pr_completion:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bash_completion
    - source:   {{ grains.stateroot }}/bash/pr_bash_completion
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if grains.cfg_bash.completion.append %}
append-source-completion:
  file.append:
    - name:     {{ grains.homedir }}/.bashrc
    - text:     source $HOME/.pr_bash_completion
    - require:
      - file:   bashrc
      - file:   pr_completion
  {% endif %}
{% endif %}

{% if files and 'bashrc' in files %}
pr_bashrc:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - source:   {{ grains.stateroot }}/bash/pr_bashrc
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644

  {% if grains.cfg_bash.bashrc.append %}
append_source-bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.bashrc
    - text:     source $HOME/.pr_bashrc
    - require:
      - file:   bashrc
      - file:   pr_bashrc
  {% endif %}
{% endif %}
