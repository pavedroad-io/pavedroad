# Install base packages

{% set installs = grains.cfg_base.installs %}

# homebrew has no firefox target, need brew cask install on MacOS

{% if installs and 'firefox' in installs and not grains.os_family == 'MacOS' %}
firefox:
  pkg.installed:
  {% if grains.os_family == 'Suse' %}
    - name:     MozillaFirefox
  {% else %}
    - name:     firefox
  {% endif %}
  {% if grains.cfg_base.firefox.version is defined %}
    - version:  {{ grains.cfg_base.firefox.version }}
  {% endif %}
{% endif %}
