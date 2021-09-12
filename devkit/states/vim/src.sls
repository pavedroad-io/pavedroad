# Install vim from source
# No redhat repos have vim 8

{% if grains.os_family == 'RedHat' %}
  {% set vim_target = 8.1 %}
  {% set vim_version = salt.cmd.shell('PATH=/usr/local/bin/:$PATH vim --version | head -1 |  egrep -o "[0-9]+\.[0-9]+"') %}
  {% set vim_prefix = '/usr/local' %}

  {% if (vim_version | float) < vim_target or grains.saltrun == 'upgrade' %}
    {% set vim_temp_dir = salt.temp.dir() %}

include:
  - redhat

vim-source:
  git.latest:
    - name:     https://github.com/vim/vim.git
    - rev:      master
    - target:   {{ vim_temp_dir }}
  pkg.installed:
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
    - name:     {{ vim_temp_dir }}/src
    - makedirs: True
    - mode:     755
  cmd.run:
    - require:
      - git:    vim-source
    - cwd:      {{ vim_temp_dir }}/src
    - umask:    022
    - name:     |
                ./configure  --prefix={{ vim_prefix }} --enable-multibyte  --with-tlib=ncurses  --enable-cscope  --enable-terminal  --with-compiledby=PavedRoad.io  --enable-perlinterp=yes  --enable-rubyinterp=yes  --enable-python3interp=yes  --enable-gui=no  --without-x  --enable-luainterp=yes --with-python3-config-dir=/usr/lib64/python3.4/config-3.4m --with-python3-command=python3.4
                make
                make install_normal
  {% endif %}
{% endif %}
