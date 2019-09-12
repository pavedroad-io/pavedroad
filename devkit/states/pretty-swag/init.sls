# Install prettyswag

{#
pretty-swag will not run on ubuntu 16.04
We get the following error with "pretty-swag -v"
    /usr/local/lib/node_modules/pretty-swag/pretty-swag.js:119
    let sep = context.items.enum.length < 4 ? "," : ",\n";
    ^^^
    SyntaxError: Block-scoped declarations (let, const, function, class) not yet supported outside
So maybe we need to check the nodejs version before trying to install pretty-swag
#}

{% set installs = grains.cfg_pretty_swag.installs %}

{% if installs and 'pretty_swag' in installs %}
  {% set pretty_swag_pkg_name = 'pretty-swag' %}
  
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

npm-installed:
  pkg.installed:
    - name: npm

pretty-swag-installed:
  npm.installed:
    - name:       {{ pretty_swag_pkg_name }}
    - require:
      - pkg:      nodejs
      - pkg:      npm

  {% if grains.cfg_pretty_swag.debug.enable %}

pretty-swag-version:
  cmd.run:
    - name:     npm bin -g {{ pretty_swag_pkg_name }} -v
  {% endif %}
{% endif %}
