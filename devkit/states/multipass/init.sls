# Install multipass

{# multipass will not run in a container or VM #}
{% if grains.docker or grains.virtual != 'physical' or
  (grains.boot_rom_version is defined
  and grains.boot_rom_version == 'VirtualBox') %}
  {% set installs = False %}
{% else %}
  {% set installs = grains.cfg_multipass.installs %}
{% endif %}

{% if installs and 'multipass' in installs %}
  {% set multipass_pkg_name = 'multipass' %}
  {% set multipass_snap_install = True %}
  {% set multipass_path = '/snap/bin/' %}
  {% set completion = grains.cfg_multipass.completion %}

  {% if grains.os_family == 'MacOS' %}
    {% set multipass_snap_install = False %}
    {% set multipass_path = '/usr/local/bin/' %}
  {% elif grains.os_family == 'Windows' %}
    {% set multipass_snap_install = False %}
  {% endif %}

  {% if multipass_snap_install %}
include:
  - snapd
  {% endif %}

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
  {% elif multipass_snap_install %}
  cmd.run:
    - require:
      - sls:    snapd
    - unless:   snap list | grep multipass
      {# SELinux is blocking multipass install hook on Centos #}
      {# TODO: remove this when no longer needed #}
    {% if grains.os_family == 'RedHat' %}
    - name:     |
                sudo setenforce 0
                snap install --beta multipass --classic
                sudo setenforce 1
    {% else %}
    - name:     snap install --beta multipass --classic
    {% endif %}
  {% else %}
  pkg.installed:
    - unless:   command -v multipass
    - name:     multipass
    {% if grains.cfg_multipass.multipass.version is defined %}
    - version:  {{ grains.cfg_multipass.multipass.version }}
    {% endif %}
  {% endif %}

  {% if completion %}
    {# Cannot find zsh completion #}
    {% if completion and 'bash' in completion %}
      {% set multipass_prefix = 'https://raw.githubusercontent.com/CanonicalLtd' %}
      {% set multipass_content = '/multipass/master/completions/bash/multipass' %}
      {% set multipass_comp_url = multipass_prefix + multipass_content %}
      {# brew cask install does not install completion #}

multipass-bash-completion:
  file.managed:
    - name:     {{ pillar.directories.completions.bash }}/multipass
    - source:   {{ multipass_comp_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
  {% endif %}

  {% if grains.cfg_multipass.debug.enable %}
multipass-version:
  cmd.run:
    - name:     {{ multipass_path }}multipass version
  {% endif %}
{% endif %}
