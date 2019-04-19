# Install golang

{% set installs = grains.cfg_golang.installs %}

{% if installs and 'golang' in installs %}
golang:
  pkg.installed:
  {% if grains.os_family == 'Suse' %}
    - name:     go
  {% else %}
    - name:     golang
  {% endif %}
  {% if grains.cfg_golang.golang.version is defined %}
    - version:  {{ grains.cfg_golang.golang.version }}
  {% endif %}
{% endif %}
