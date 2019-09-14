# Install prettyswag

{#
pretty-swag will not run on ubuntu 16.04
We get the following error with "pretty-swag -v"
    /usr/local/lib/node_modules/pretty-swag/pretty-swag.js:119
    let sep = context.items.enum.length < 4 ? "," : ",\n";
    ^^^
    SyntaxError: Block-scoped declarations (let, const, function, class) not yet supported outside
For now, checking Ubuntu version and skipping pretty-swag installation if version = xenial
In the future, we may prefer to separate the node install into its own state,
especially if it is to be used for more than just pretty-swag
We can then make npm plugin installations dependent on the installed nodejs version:
  set node_ver = salt['cmd.shell']('nodejs -v | cut -d v -f2 | cut -d . -f1') | int
  if node_ver >= 8
  include:
    pretty-swag
  ...
#}

{% if grains.os_family == 'Debian' %}
  {% set version_codename = salt['cmd.shell']('grep VERSION_CODENAME /etc/os-release | cut -d = -f2') %}
{% else %}
  {% set version_codename = '' %}
{% endif %}


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

  {% if version_codename != 'xenial' %}

pretty-swag-installed:
  npm.installed:
    - name:       {{ pretty_swag_pkg_name }}
    - require:
      - pkg:      nodejs
      - pkg:      npm

    {% if grains.cfg_pretty_swag.debug.enable %}

pretty-swag-version:
  cmd.run:
    - name:     $(npm bin -g)/{{ pretty_swag_pkg_name }} -v
    {% endif %}
  {% endif %}
{% endif %}
