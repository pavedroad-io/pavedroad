# Install vim from source
# No redhat repos have vim 8

{% if grains.os_family == 'RedHat' %}
  {% set vim_version = 'Vi IMproved 8' %}
  {% set get_version = 'PATH=/usr/local/bin/:$PATH vim --version | head -1' %}
  {% set check_version = get_version + ' | grep "' + vim_version + '"' %}
  {% set vim_prefix = '/usr/local' %}

include:
  - redhat

vim-source:
  git.latest:
    - unless:   {{ check_version }}
    - name:     https://github.com/vim/vim.git
    - rev:      master
    - target:   /tmp/vim
  pkg.installed:
    - unless:   {{ check_version }}
    - pkgs:
      - ncurses-devel
      - perl-devel
      - perl-ExtUtils-CBuilder
      - perl-ExtUtils-Embed
  {% if grains.os == 'CentOS' %}
      - ruby-devel
      - gpm-devel
    {% if grains.osmajorrelease <= 7 %}
      - lua-devel
    {% endif %}
  {% endif %}
  {% if grains.os == 'CentOS' and grains.osmajorrelease >= 8 %}
      - python36-devel
  {% else %}
      - python34-devel
  {% endif %}
  file.directory:
    - name:     /tmp/vim/src
    - makedirs: True
    - mode:     755
  cmd.run:
    - unless:   {{ check_version }}
    - require:
      - git:    vim-source
    - cwd:      /tmp/vim/src
    - umask:    022
    - name:     |
                ./configure  --prefix={{ vim_prefix }} --enable-multibyte  --with-tlib=ncurses  --enable-cscope  --enable-terminal  --with-compiledby=PavedRoad.io  --enable-perlinterp=yes  --enable-rubyinterp=yes  --enable-python3interp=yes  --enable-gui=no  --without-x  --enable-luainterp=yes --with-python3-config-dir=/usr/lib64/python3.4/config-3.4m --with-python3-command=python3.4
                make
                make install_normal
{% endif %}
