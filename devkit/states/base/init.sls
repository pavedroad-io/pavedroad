# Install base packages

{% set installs = grains.cfg_base.installs %}

{# Do not install firefox in docker container #}
{% if installs and 'firefox' in installs and not grains.docker %}
  {% set repo_disable = False %}

  {# Workaround to disable/re-enable repo that causes salt install to fail #}
  {% if grains.os_family == 'Suse' and grains.osfullname == 'Leap' and
    grains.osrelease == '15.1' %}
    {% set firefox_repo_disable = True %}
    {% set firefox_repo_name = 'openSUSE-Leap-15.1-Update' %}
  {% endif %}

  {% if grains.os_family == 'MacOS' %}
firefox:
  cmd.run:
    - unless:   test -d /Applications/Firefox.app
    - name:     brew cask install firefox
  {% else %}
    {% if firefox_repo_disable %}
repo-disable:
  pkgrepo.managed:
    - name:     {{ firefox_repo_name }}
    - enabled:  False
    {% endif %}
firefox-install:
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
  {% if firefox_repo_disable %}
repo-reenable:
  pkgrepo.managed:
    - name:     {{ firefox_repo_name }}
    - enabled:  True
  {% endif %}
{% endif %}
