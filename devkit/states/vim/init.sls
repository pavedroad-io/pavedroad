# Install vim and go plugins
# Copy and source vimrc and plugin init files

{% set installs = grains.cfg_vim.installs %}
{% set files = grains.cfg_vim.files %}

{% if installs and 'vim' in installs %}
  {% set vim_pkg_name = 'vim' %}
  {% set vim_src_install = False %}
  {% set vim_path = "" %}

  {% if grains.os_family == 'RedHat' %}
    {% set vim_pkg_name = 'vim-enhanced' %}
  {% endif %}

  {% if grains.os_family == 'RedHat' and not grains.os == 'Fedora' %}
    {% set vim_src_install = True %}
    {% set vim_path = "/usr/local/bin/" %}
  {% endif %}

include:
  - pip3
  {% if grains.os_family == 'Debian' %}
  - locales
  {% endif %}
  {% if vim_src_install %}
  - vim.src
  {% endif %}

  {% if not vim_src_install %}
vim:
  pkg.installed:
    - name:     {{ vim_pkg_name }}
    {% if grains.cfg_vim.vim.version is defined %}
    - version:  {{ grains.cfg_vim.vim.version }}
    {% endif %}
    {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ vim_pkg_name }}
    {% else %}
    - unless:   command -v vim
    {% endif %}
  {% endif %}
viminfo:
  file.managed:
    - name:     {{ grains.homedir }}/.viminfo
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
    - replace:  False
{% endif %}

{% if installs and 'go-plugins' in installs %}
vim-autoload:
  file.managed:
    - name:     {{ grains.homedir }}/.vim/autoload/plug.vim
    - source:   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    - makedirs: True
    - skip_verify: True
    - replace:  False
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
vim-plugged:
  file.directory:
    - name:     {{ grains.homedir }}/.vim/plugged
    - makedirs: True
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     755
vimrc-plug:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_vimrc_plug
    - source:   salt://vim/pr_vimrc_plug
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
vimrc-init:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_vimrc_init
    - source:   salt://vim/pr_vimrc_init
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
pynvim-dep:
  cmd.run:
    - unless:   pip3 list | grep pynvim
    - name:     pip3 install pynvim
    - require:
      - sls:    pip3
neovim-dep:
  cmd.run:
    - unless:   pip3 list | grep neovim
    - name:     pip3 install neovim
    - require:
      - cmd:    pynvim-dep
vim-plugins:
  cmd.run:
    {# Fix for Centos ignoring "runas" leaving files with owner/group == root/root #}
    {% if not grains.docker and grains.os_family == 'RedHat' %}
    - name:     sudo -u {{ grains.realuser }} {{ vim_path }}vim -e -s -u {{ grains.homedir }}/.pr_vimrc_plug +PlugInstall +qall
    {% else %}
    - name:     {{ vim_path }}vim -e -s -u {{ grains.homedir }}/.pr_vimrc_plug +PlugInstall +qall
    {% endif %}
    {# Salt cannot retrieve environment for "runas" on MacOS not being run with sudo #}
    {% if not grains.os_family == 'MacOS' %}
    - runas:    {{ grains.realuser }}
      {# Salt requires sudo for "group" here, so MacOS and Docker excluded #}
      {% if not grains.docker %}
    - group:    {{ grains.realgroup }}
      {% endif %}
    {% endif %}
    - timeout:  120
    - use_vt:   True
    - require:
      - file:   vim-autoload
      - file:   vim-plugged
      - file:   vimrc-plug
      - cmd:    neovim-dep
    - unless:
      -         test -d {{ grains.homedir }}/.vim/plugged/deoplete-go
      -         test -d {{ grains.homedir }}/.vim/plugged/deoplete.nvim
      -         test -d {{ grains.homedir }}/.vim/plugged/nvim-yarp
      -         test -d {{ grains.homedir }}/.vim/plugged/vim-go
      -         test -d {{ grains.homedir }}/.vim/plugged/vim-hug-neovim-rp

# Centos ignores "runas" above so owner/group == root/root must be fixed
  {% if grains.os_family == 'RedHat' %}
chown-vim-tree:
  file.directory:
    - name:     {{ grains.homedir }}/.vim
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - recurse:
      - user
      - group
    - require:
      - cmd:    vim-plugins
  {% endif %}
{% endif %}

{% if files and 'vimrc' in files %}
vimrc:
  file.managed:
    - name:     {{ grains.homedir }}/.vimrc
    - source:   https://raw.githubusercontent.com/vim/vim/master/runtime/vimrc_example.vim
    - skip_verify: True
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
    - replace:  False

  {% if grains.cfg_vim.vimrc.append %}
append-source-vimrc:
  file.append:
    - name:     {{ grains.homedir }}/.vimrc
    - text:     source $HOME/.pr_vimrc_init
    - require:
      - file:   vimrc-plug
      - file:   vimrc-init
  {% endif %}
  {% if grains.cfg_vim.debug.enable %}
vim-version:
  cmd.run:
    - name:     {{ vim_path }}vim -u NONE --version
vim-plugin-ls:
  cmd.run:
    - name:     ls -l {{ grains.homedir }}/.vim/plugged
  {% endif %}
{% endif %}
