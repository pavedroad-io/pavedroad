# Install nodejs and npm

{% set installs = grains.cfg_nodejs.installs %}

{% if installs and 'nodejs' in installs %}
  {% set nodejs_pkg_name = 'nodejs' %}
  {% if grains.os_family == 'Suse' %}
    {% set nodejs_pkg_name = 'nodejs10' %}
  {% endif %}
  {% set nodejs_bin_name = 'node' %}
  {% set npm_pkg_name = 'npm' %}

nodejs-installed:
  pkg.installed:
    - unless:   command -v {{ nodejs_bin_name }}
    - name:     {{ nodejs_pkg_name }}
  {% if grains.cfg_nodejs.nodejs.version is defined %}
    - version:  {{ grains.cfg_nodejs.nodejs.version }}
  {% endif %}
  {# Ubuntu does not include npm in nodejs install #}
  {% if grains.os == 'Ubuntu' %}
npm-installed:
  pkg.installed:
    - unless:   command -v {{ npm_pkg_name }}
    - name:     {{ npm_pkg_name }}
  cmd.run:
    - onlyif:   command -v {{ npm_pkg_name }}
    - name:     {{ npm_pkg_name }} install npm@latest -g
  {% endif %}

  {# Fix "npm-default is unavailable" error #}
  {% if grains.os_family == 'Suse' %}
  file.symlink:
    - onlyif:   test -x /etc/alternatives/node-default
    - unless:   test -x /usr/bin/npm-default
    - name:     /usr/bin/npm-default
    - target:   /etc/alternatives/node-default
  {# Many apps expect a "node" binary #}
  {% elif grains.os_family in ('Debian', 'RedHat') %}
  file.symlink:
    - onlyif:   test -x /usr/bin/nodejs
    - unless:   test -x /usr/bin/node
    - name:     /usr/bin/node
    - target:   /usr/bin/nodejs
  {% endif %}

  {% if grains.cfg_nodejs.debug.enable %}
nodejs-version:
  cmd.run:
    - name:     node --version
npm-version:
  cmd.run:
    - name:     npm --version
  {% endif %}
{% endif %}
