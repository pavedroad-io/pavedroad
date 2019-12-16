# Install prettyswag

{#
pretty-swag will not run on Ubuntu 16.04 due to node v4
We get the following error with "pretty-swag -v"
    /usr/local/lib/node_modules/pretty-swag/pretty-swag.js:119
    let sep = context.items.enum.length < 4 ? "," : ",\n";
    ^^^
    SyntaxError: Block-scoped declarations (let, const, function, class) not yet supported outside
#}

{% set pretty_swag_installs = grains.cfg_pretty_swag.installs %}
{% set osmajorrelease = grains.osmajorrelease | int %}

{% if pretty_swag_installs and 'pretty_swag' in pretty_swag_installs %}
  {% set pretty_swag_pkg_name = 'pretty-swag' %}

  {# If OS is Ubuntu, only install on 18.04+ #}
  {% if (grains.os != 'Ubuntu') or (osmajorrelease >= 18) %}
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
