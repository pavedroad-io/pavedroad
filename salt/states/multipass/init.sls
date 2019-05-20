# Install multipass

{% set installs = grains.cfg_multipass.installs %}

{% if installs and 'multipass' in installs %}
  {% set multipass_supported = False %}

  {% if grains.os_family == 'Debian' %}
    {% set multipass_supported = True %}
  {% endif %}

  {% if multipass_supported %}
multipass:
    {% if grains.os_family == 'MacOS' %}
  cmd.run:
    - name:     brew cask install multipass
# The following worked for casks previously
#   pkg.installed:
#     - name:     caskroom/casks/multipass
# but now salt produces this error:
#   Failure while executing; git clone https://github.com/caskroom/homebrew-casks
# due to homebrew cask project moving to github.com/Homebrew/homebrew-cask
# searches for casks and caskroom in Homebrew project return nada
    {% else %}
  pkg.installed:
      - name:     multipass
      {% if grains.cfg_multipass.multipass.version is defined %}
      - version:  {{ grains.cfg_multipass.multipass.version }}
      {% endif %}
    {% endif %}

    {% if grains.cfg_multipass.debug.enable %}
multipass-version:
  cmd.run:
    - name: multipass version
    {% endif %}
  {% endif %}
{% endif %}
