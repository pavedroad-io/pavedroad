# Install vim and copy/source vimrc file

{% set installs = grains.cfg_vim.installs %}
{% set files = grains.cfg_vim.files %}

{% if installs and 'vim' in installs %}
  {% set vim_pkg_name = 'vim' %}
  {% set vim_alt_install = False %}

  {% if grains.os_family == 'RedHat' %}
    {% set vim_pkg_name = 'vim-enhanced' %}
  {% endif %}

vim:
  pkg.installed:
    - name:     {{ vim_pkg_name }}
  {% if grains.cfg_vim.vim.version is defined %}
    - version:  {{ grains.cfg_vim.vim.version }}
  {% endif %}
{% endif %}

{% if installs and 'vim-go' in installs %}
vim-go:
  cmd.run:
    - name: |
                curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
                git clone https://github.com/fatih/vim-go.git ~/.vim/plugged/vim-go
vimrc-go:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_vimrc_go
    - source:   {{ grains.stateroot }}/vim/pr_vimrc_go
    - user:     {{ grains.username }}

  {% if grains.cfg_vim.vimrc_go.prepend %}
prepend-source-vimrc-go:
  file.prepend:
    - name:     {{ grains.homedir }}/.vimrc
    - text:     source $HOME/.pr_vimrc_go
    - require:
      - file:   vimrc-go
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
      - file:   vimrc
  {% endif %}
{% endif %}
