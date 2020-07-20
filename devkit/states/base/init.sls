# Install base packages - only firefox as base browser for now

{% set installs = grains.cfg_base.installs %}

{# Do not install firefox in docker container #}
{% if installs and 'firefox' in installs and not grains.docker %}
  {% set firefox_bin_name = 'firefox' %}
  {% set firefox_pkg_name = 'firefox' %}
  {% set firefox_path = '/usr/bin' %}
  {% set firefox_repo_disable = False %}

  {% if grains.os_family == 'Suse' %}
    {% set firefox_pkg_name = 'MozillaFirefox' %}
  {% endif %}

  {% if grains.cfg_base.firefox.version is defined and
    grains.cfg_base.firefox.version != 'latest' %}
    {% set firefox_version = grains.cfg_base.firefox.version %}
  {% else %}
    {% set firefox_version = 'latest' %}
  {% endif %}

  {# Cask install required on MacOS #}
  {% if grains.os_family == 'MacOS' %}
firefox-cask:
  cmd.run:
    - unless:   test -d /Applications/Firefox.app
    - name:     brew cask install firefox
  {% else %}
firefox-package:
  pkg.installed:
    - unless:   command -v {{ firefox_bin_name }}
    - name:     {{ firefox_pkg_name }}
    - version:  {{ firefox_version }}
  {% endif %}

  {% if grains.cfg_base.firefox.debug.enable %}
firefox-version:
  cmd.run:
    - name:     {{ firefox_path }}/{{ firefox_bin_name }} --version
  {% endif %}
{% endif %}
