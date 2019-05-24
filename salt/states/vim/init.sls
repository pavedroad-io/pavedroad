# Install vim and vim-go plugin
# Copy and source vimrc and vimrc-go files

{% set installs = grains.cfg_vim.installs %}
{% set files = grains.cfg_vim.files %}

{% if installs and 'vim' in installs %}
  {% set vim_pkg_name = 'vim' %}
  {% set vim_src_install = False %}
  {% set vim_path = "" %}

  {% if grains.os_family == 'RedHat' %}
    {% set vim_src_install = True %}
    {% set vim_path = "/usr/local/bin/" %}
  {% endif %}

include:
  - pip3
  {% if vim_src_install %}
  - vim.src
  {% endif %}

  {% if not vim_src_install %}
vim:
  pkg.installed:
    - unless:   command -v vim
    - name:     {{ vim_pkg_name }}
    {% if grains.cfg_vim.vim.version is defined %}
    - version:  {{ grains.cfg_vim.vim.version }}
    {% endif %}
    {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ vim_pkg_name }}
    {% endif %}
  {% endif %}
{% endif %}

{% if installs and 'vim-go' in installs %}
plug-vim:
  cmd.run:
    - unless:   test -x {{ grains.homedir }}/.vim/autoload/plug.vim
    - name:     curl -fLo {{ grains.homedir }}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  file.directory:
    - name:     {{ grains.homedir }}/.vim/plugged
    - user:     {{ grains.username }}
    - makedirs: True
    - mode:     755
vimrc-plug:
  file.managed:
    - unless:   test -x {{ grains.homedir }}/.pr_vimrc_plug
    - name:     {{ grains.homedir }}/.pr_vimrc_plug
    - source:   {{ grains.stateroot }}/vim/pr_vimrc_plug
    - user:     {{ grains.username }}
vimrc-go:
  file.managed:
    - unless:   test -x {{ grains.homedir }}/.pr_vimrc_go
    - name:     {{ grains.homedir }}/.pr_vimrc_go
    - source:   {{ grains.stateroot }}/vim/pr_vimrc_go
    - user:     {{ grains.username }}
vim-plugin-deps:
  cmd.run:
    - unless:   pip3 list | grep pynvim
    - name:     pip3 install --user pynvim
    - require:
      - sls:    pip3
vim-plugins:
  cmd.run:
    - name:     {{ vim_path }}vim -u {{ grains.homedir }}/.pr_vimrc_plug +PlugInstall +qall
    - timeout:  120
    - use_vt:   True
    - require:
      - cmd:    plug-vim
      - file:   plug-vim
      - file:   vimrc-plug
      - cmd:    vim-plugin-deps
  {% if grains.cfg_vim.vimrc_go.prepend %}
prepend-source-vimrc-go:
  file.prepend:
    - name:     {{ grains.homedir }}/.vimrc
    - text:     source $HOME/.pr_vimrc_go
    - require:
      - file:   vimrc-go
prepend-source-vimrc-plug:
  file.prepend:
    - name:     {{ grains.homedir }}/.vimrc
    - text:     source $HOME/.pr_vimrc_plug
    - require:
      - file:   vimrc-plug
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
  {% if grains.cfg_vim.debug.enable %}
vim-version:
  cmd.run:
    - name:     {{ vim_path }}vim --version
vim-plugin-ls:
  cmd.run:
    - name:     ls -l {{ grains.homedir }}/.vim/plugged
  {% endif %}
{% endif %}
