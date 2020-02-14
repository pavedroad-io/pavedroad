# Install prettyswag

{% set pretty_swag_installs = grains.cfg_pretty_swag.installs %}

{% if pretty_swag_installs and 'pretty_swag' in pretty_swag_installs %}
  {% set pretty_swag_pkg_name = 'pretty-swag' %}

include:
  - nodejs

  {# If OS is Ubuntu, only install on 18.04+ #}
  {% if (grains.os != 'Ubuntu') or (grains.osmajorrelease >= 18) %}
pretty-swag-installed:
  npm.installed:
    - name:       {{ pretty_swag_pkg_name }}
    - require:
      - sls:      nodejs

    {% if grains.cfg_pretty_swag.debug.enable %}
pretty-swag-version:
  cmd.run:
    - name:     $(npm bin -g)/{{ pretty_swag_pkg_name }} -v
    {% endif %}
  {% endif %}
{% endif %}
