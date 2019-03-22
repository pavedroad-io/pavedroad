# Install vim and copy/source config file

vim:
  pkg.installed

copy-vim-config:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_vimrc
    - source:   {{ grains.stateroot }}/vim/pr_vimrc
    - user:     {{ grains.username }}

source-vim-config:
  file.append:
    - name:     {{ grains.homedir }}/.vimrc
    - text:     source $HOME/.pr_vimrc
