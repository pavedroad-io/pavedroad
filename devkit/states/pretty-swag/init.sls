# Install prettyswag

{% set pretty_swag_installs = grains.cfg_pretty_swag.installs %}

{% if pretty_swag_installs and 'pretty_swag' in pretty_swag_installs %}
  {% set pretty_swag_pkg_name = 'pretty-swag' %}

include:
  - nodejs

pretty-swag-installed:
{# npm.installed fails even when install succeeds (weird json output)
  npm.installed:
    - name:     {{ pretty_swag_pkg_name }}
#}
  cmd.run:
    - name:     npm install {{ pretty_swag_pkg_name }} -g
    - require:
      - sls:    nodejs

  {% if grains.cfg_pretty_swag.debug.enable %}
pretty-swag-version:
  cmd.run:
    - name:     $(npm bin -g)/{{ pretty_swag_pkg_name }} -v
  {% endif %}
{% endif %}
