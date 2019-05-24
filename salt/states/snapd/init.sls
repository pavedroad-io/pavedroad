# Install snapd

{% if grains.docker %}
  {% set installs = False %}
{% else %}
  {% set installs = grains.cfg_snapd.installs %}
{% endif %}

# Assuming Debian systems already have snapd installed

{% if installs and 'snapd' in installs %}
  {% set snapd_install_needed = False %}

  {% if grains.os_family == 'Suse' %}
    {% set snapd_install_needed = True %}
    {% set suse_path = 'https://download.opensuse.org/repositories/system:/snappy/' %}
    {% set suse_repo_url = suse_path + 'openSUSE_Leap_' + grains.osrelease %}
    {% set suse_repo_name = 'openSUSE_Leap_' + grains.osrelease + '_snappy' %}
  {% elif grains.os_family == 'RedHat' %}
    {% set snapd_install_needed = True %}
  {% endif %}

  {% if snapd_install_needed %}
snapd:
    {% if grains.os_family == 'Suse' %}
  pkgrepo.managed:
    - unless:    zypper repos | grep {{ suse_repo_name }}
    - name:      {{ suse_repo_name }}
    - humanname: openSUSE snapd repository
    - enabled:   True
    - refresh:   True
    - baseurl:   {{ suse_repo_url }}
    - gpgcheck:  False
    {% endif %}
  pkg.installed:
    - unless:   command -v snap
    - name:     snapd
    {% if grains.cfg_snapd.snapd.version is defined %}
    - version:  {{ grains.cfg_snapd.snapd.version }}
    {% endif %}
    {% if grains.os_family == 'RedHat' %}
service-stop:
  service.dead:
    - name:     snapd.service
    - enable:   True
    - init_delay: 10
    - require:
      - pkg:    snapd
socket-start:
  service.running:
    - name:     snapd.socket
    - reload:   True
    - init_delay: 10
    - require:
      - pkg:    snapd
    {% else %}
snapd-start:
  service.running:
    - name:     snapd
    - enable:   True
    - init_delay: 10
    - require:
      - pkg:    snapd
    {% endif %}
    {% if grains.os_family == 'RedHat' %}
  cmd.run:
    - unless:   test -x /snap
    - name:     $(command -v sudo) ln -s /var/lib/snapd/snap /snap
    {% endif %}
snapd-wait:
  cmd.run:
    - name:     $(command -v sudo) snap wait system seed.loaded
    - timeout:  20
  {% endif %}

  {% if grains.cfg_snapd.debug.enable %}
snapd-version:
  cmd.run:
    - name:     snap version
  {% endif %}
{% endif %}
