# Install vim from source
# No redhat repos have vim 8

{% if grains.os_family == 'RedHat' %}
  {% set version_8_1 = "PATH=/usr/local/bin/:$PATH vim --version | head -1 | grep 8.1" %}
  {% set vim_prefix = "/usr/local/bin" %}

include:
  - redhat

vim-source:
  git.latest:
    - unless:   {{ version_8_1 }}
    - name:     https://github.com/vim/vim.git
    - rev:      master
    - target:   /tmp/vim
    - user:     {{ grains.username }}
    - force_clone: True
  pkg.installed:
    - unless:   {{ version_8_1 }}
  {% if grains.os == 'CentOS' %}
    - pkgs:
      - ncurses-devel
      - perl-devel
      - perl-ExtUtils-CBuilder
      - perl-ExtUtils-Embed
      - python34-devel
      - lua-devel
      - ruby-devel
      - gpm-devel
  {% else %}
    - pkgs:
      - ncurses-devel
      - perl-devel
      - perl-ExtUtils-CBuilder
      - perl-ExtUtils-Embed
      - python34-devel
  {% endif %}
  file.directory:
    - name:     /tmp/vim/src
    - user:     {{ grains.username }}
    - makedirs: True
    - mode:     755
  cmd.run:
    - unless:   {{ version_8_1 }}
    - require:
      - git:    vim-source
    - cwd:      /tmp/vim/src
    - user:     {{ grains.username }}
    - name:     |
                ./configure  --prefix={{ vim_prefix }} --enable-multibyte  --with-tlib=ncurses  --enable-cscope  --enable-terminal  --with-compiledby=PavedRoad.io  --enable-perlinterp=yes  --enable-rubyinterp=yes  --enable-python3interp=yes  --enable-gui=no  --without-x  --enable-luainterp=yes --with-python3-config-dir=/usr/lib64/python3.4/config-3.4m --with-python3-command=python3.4
                make
                make install
{% endif %}
