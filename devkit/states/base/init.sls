# Install base packages

{% set installs = grains.cfg_base.installs %}

{% if installs and 'firefox' in installs %}
firefox:
  {% if grains.os_family == 'MacOS' %}
  cmd.run:
    - unless:   test -d /Applications/Firefox.app
    - name:     brew cask install firefox
  {% else %}
  pkg.installed:
    - unless:   command -v firefox
    {% if grains.os_family == 'Suse' %}
    - name:     MozillaFirefox
    {% else %}
    - name:     firefox
    {% endif %}
  {% endif %}
  {% if grains.cfg_base.firefox.version is defined %}
    - version:  {{ grains.cfg_base.firefox.version }}
  {% endif %}
{% endif %}
