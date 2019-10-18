# Install graphviz

{% set installs = grains.cfg_graphviz.installs %}

{% if installs and 'graphviz' in installs %}
  {% set graphviz_pkg_name = 'graphviz' %}
  {% set graphviz_util_name = 'dot' %}
graphviz:
  pkg.installed:
    - unless:   command -v {{ graphviz_util_name }}
    - name:     {{ graphviz_pkg_name }}
  {% if grains.cfg_graphviz.graphviz.version is defined %}
    - version:  {{ grains.cfg_graphviz.graphviz.version }}
  {% endif %}
  {% if grains.cfg_graphviz.debug.enable %}
graphviz-version:
  cmd.run:
    - name:     {{ graphviz_util_name }} -V
  {% endif %}
{% endif %}
