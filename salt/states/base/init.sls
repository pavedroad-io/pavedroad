# Install base packages

{% set installs = grains.cfg_base.installs %}

# homebrew has no firefox target, need brew cask install on MacOS

{% if installs and 'firefox' in installs and not grains.os == 'MacOS' %}
firefox:
  pkg.installed:
    - name:     firefox
  {% if grains.cfg_base.firefox.version is defined %}
    - version:  {{ grains.cfg_base.firefox.version }}
  {% endif %}
{% endif %}
