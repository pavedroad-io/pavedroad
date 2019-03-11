# Copy and source bash config files

copy-bash-profile:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bash_profile
    - source:   {{ grains.stateroot }}/bash/pr_bash_profile
    - user:     {{ grains.username }}

source-bash-profile:
  file.append:
    - name:     {{ grains.homedir }}/.bash_profile
    - text:     source $HOME/.pr_bash_profile

copy-bash-aliases:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - source:   {{ grains.stateroot }}/bash/pr_bashrc
    - user:     {{ grains.username }}

source-bash-aliases:
  file.append:
    - name:     {{ grains.homedir }}/.bashrc
    - text:     source $HOME/.pr_bashrc
