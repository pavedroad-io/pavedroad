# Install jq

{% set installs = grains.cfg_jq.installs %}
{% set jq_pkg_name = 'jq' %}

{% if installs and 'jq' in installs %}

jq:
  pkg.installed:
  {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ jq_pkg_name }}
  {% else %}
    - unless:   command -v {{ jq_pkg_name }}
  {% endif %}
    - name:     {{ jq_pkg_name }}
  {% if grains.cfg_jq.jq.version is defined %}
    - version:  {{ grains.cfg_jq.jq.version }}
  {% endif %}

  {% if grains.cfg_jq.debug.enable %}
jq-version:
  cmd.run:
    - name:     {{ jq_pkg_name }} --version
  {% endif %}
{% endif %}

