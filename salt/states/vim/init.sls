# Install vim and copy/source vimrc file

{% set installs = grains.cfg_vim.installs %}
{% set files = grains.cfg_vim.files %}

{% if installs and 'vim' in installs %}
vim:
  pkg.installed:
  {% if grains.os_family == 'RedHat' %}
    - name:     vim-enhanced
  {% else %}
    - name:     vim
  {% endif %}
  {% if grains.cfg_vim.vim.version is defined %}
    - version:  {{ grains.cfg_vim.vim.version }}
  {% endif %}
{% endif %}

{% if files and 'vimrc' in files %}
vimrc:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_vimrc
    - source:   {{ grains.stateroot }}/vim/pr_vimrc
    - user:     {{ grains.username }}

  {% if grains.cfg_vim.vimrc.append %}
append-source-vimrc:
  file.append:
    - name:     {{ grains.homedir }}/.vimrc
    - text:     source $HOME/.pr_vimrc
    - require:
      - file: vimrc
  {% endif %}
{% endif %}
