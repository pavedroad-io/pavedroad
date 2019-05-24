# Copy and source bash config files

{% set files = grains.cfg_bash.files %}

{% if files and 'profile' in files %}
profile:
  file.managed:
    - unless:   test -x {{ grains.homedir }}/.pr_bash_profile
    - name:     {{ grains.homedir }}/.pr_bash_profile
    - source:   {{ grains.stateroot }}/bash/pr_bash_profile
    - user:     {{ grains.username }}

  {% if grains.cfg_bash.profile.append %}
append-source-profile:
  file.append:
    - name:     {{ grains.homedir }}/.bash_profile
    - text:     source $HOME/.pr_bash_profile
    - require:
      - file: profile
  {% endif %}
{% endif %}

{% if files and 'bashrc' in files %}
bashrc:
  file.managed:
    - unless:   test -x {{ grains.homedir }}/.pr_bashrc
    - name:     {{ grains.homedir }}/.pr_bashrc
    - source:   {{ grains.stateroot }}/bash/pr_bashrc
    - user:     {{ grains.username }}

  {% if grains.cfg_bash.bashrc.append %}
append_source-bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.bashrc
    - text:     source $HOME/.pr_bashrc
    - require:
      - file: bashrc
  {% endif %}
{% endif %}
