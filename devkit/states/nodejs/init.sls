# Install nodejs and npm

{% set installs = grains.cfg_nodejs.installs %}

{% if installs and 'nodejs' in installs %}

nodejs-installed:
  pkg.installed:
    - name: nodejs
  {# pretty-swag expects a "node" binary #}
  {% if not grains.os_family == 'MacOS' %}
  file.symlink:
    - onlyif:   test -x /usr/bin/nodejs
    - unless:   test -x /usr/bin/node
    - name:     /usr/bin/node
    - target:   /usr/bin/nodejs
  {% endif %}

nodejs-version:
  cmd.run:
    - name:     node -v

npm-installed:
  pkg.installed:
    - name: npm

# Include npm plugins
include:
  - pretty-swag

{% endif %}
