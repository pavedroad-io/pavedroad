# Install base packages

{% set installs = grains.cfg_base.installs %}

{#
We get the following error on ubuntu 16.04:
    UnicodeDecodeError: 'utf8' codec can't decode byte 0xbd in position 21: invalid start byte
The following LANG settings fixes this problen in a docker container:
    docker run -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -it -v $(pwd):/vol xenial:salted bash
So the preference is to set the locale in our base install state
Copied below from https://docs.saltstack.com/en/latest/ref/states/all/salt.states.locale.html
Possible only set the locale for specific OSes like ubuntu 16.04
This has not been tested
#}

us_locale:
  locale.present:
    - name: en_US.UTF-8

default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: us_locale

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
