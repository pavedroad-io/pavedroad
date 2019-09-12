# Installs locales package if not present
# Installs locale en_US.UTF-8 if not present
# Sets env variable LC_ALL="en_US.UTF-8" to avoid system default locale change
#
# required to install vim plugins on Ubuntu 16.04

{% if grains.os_family == 'Debian' %}
    {% set locales_pkg_name = 'locales' %}
{% endif %}

locales:
  pkg.installed:
    - name:     {{ locales_pkg_name }}
    - unless:   command -v locale-gen

us_locale:
  locale.present:
    - name:     en_US.UTF-8
    - require:
      - pkg:    locales

lc_all_env:
  environ.setenv:
    - name:     LC_ALL
    - value:    en_US.UTF-8
