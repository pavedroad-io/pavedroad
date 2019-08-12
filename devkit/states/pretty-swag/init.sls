# Install prettyswag

{% set installs = grains.cfg_pretty_swag.installs %}

{% if installs and 'pretty_swag' in installs %}
  {% set pretty_swag_pkg_name = 'pretty-swag' %}
  
npm-installed:
  pkg.installed:
    - name: npm

pretty-swag-installed:
  npm.installed:
    - name:       {{ pretty_swag_pkg_name }}
    - require:
      - pkg:      npm

  {% if grains.cfg_pretty_swag.debug.enable %}
pretty-swag-version:
  cmd.run:
    - name:     $(npm bin -g)/{{ pretty_swag_pkg_name }} -v
  {% endif %}
{% endif %}
