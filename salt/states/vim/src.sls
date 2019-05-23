# Install vim from source
# No redhat repos have vim 8

{% if grains.os_family == 'RedHat' %}

include:
  - redhat

vim-source:
  git.latest:
    - unless:   vim --version | grep "Vi IMproved 8.1"
    - name:     https://github.com/vim/vim.git
    - rev:      master
    - target:   /tmp/vim
    - user:     {{ grains.username }}
    - force_clone: True
  pkg.installed:
    - unless:   vim --version | grep "Vi IMproved 8.1"
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
    - unless:   vim --version | grep "Vi IMproved 8.1"
    - require:
      - git:    vim-source
    - cwd:      /tmp/vim/src
    - user:     {{ grains.username }}
    - name:     |
                ./configure  --enable-multibyte  --with-tlib=ncurses  --enable-cscope  --enable-terminal  --with-compiledby=PavedRoad.io  --enable-perlinterp=yes  --enable-rubyinterp=yes  --enable-python3interp=yes  --enable-gui=no  --without-x  --enable-luainterp=yes --with-python3-config-dir=/usr/lib64/python3.4/config-3.4m --with-python3-command=python3.4
                make
                make install
{% endif %}
