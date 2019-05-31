# Install multipass

{% set installs = grains.cfg_multipass.installs %}

{% if installs and 'multipass' in installs %}
  {% set multipass_pkg_name = 'multipass' %}
  {% set multipass_supported = True %}
  {% set multipass_snap_install = True %}
  {% set multipass_path = '/snap/bin/' %}
  {% set snapd_required = True %}

  {% if grains.docker %}
    {% set multipass_supported = False %}
  {% elif grains.os_family == 'MacOS' %}
    {% set multipass_snap_install = False %}
    {% set multipass_path = '/usr/local/bin/' %}
  {% elif grains.os_family == 'Windows' %}
    {% set multipass_snap_install = False %}
  {% endif %}

  {% if multipass_supported and multipass_snap_install and snapd_required %}
include:
  - snapd
  {% endif %}

  {% if multipass_supported %}
multipass:
    {% if grains.os_family == 'MacOS' %}
  cmd.run:
    - unless:   command -v multipass
    - name:     brew cask install multipass
# The following worked for casks previously
#   pkg.installed:
#     - name:     caskroom/casks/multipass
# but now salt produces this error:
#   Failure while executing; git clone https://github.com/caskroom/homebrew-casks
# due to homebrew cask project moving to github.com/Homebrew/homebrew-cask
# searches for casks and caskroom in Homebrew project return nada
    {% elif snapd_required %}
  cmd.run:
    - require:
      - sls:    snapd
    - unless:   snap list | grep multipass
    - name:     snap install --beta multipass --classic
    {% else %}
  pkg.installed:
    - unless:   command -v multipass
    - name:     multipass
      {% if grains.cfg_multipass.multipass.version is defined %}
    - version:  {{ grains.cfg_multipass.multipass.version }}
      {% endif %}
    {% endif %}

    {% if grains.cfg_multipass.debug.enable %}
multipass-version:
  cmd.run:
    - name:     {{ multipass_path }}multipass version
    {% endif %}
  {% endif %}
{% endif %}
