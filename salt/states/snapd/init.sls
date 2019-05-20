# Install snapd

{% set installs = grains.cfg_snapd.installs %}

# Assuming Debian systems already have snapd installed

{% if installs and 'snapd' in installs %}
  {% set snapd_supported = True %}
  {% set snapd_install_needed = False %}

  {% if grains.os_family == 'RedHat' %}
    {% set snapd_install_needed = True %}
  {% elif grains.os_family == 'Suse' %}
    {% set snapd_install_needed = True %}
    {% set suse_path = 'https://download.opensuse.org/repositories/system:/snappy/' %}
    {% set suse_repo = suse_path + 'openSUSE_Leap_' + grains.osrelease %}
  {% elif grains.os_family == 'MacOS' %}
    {% set snapd_supported = False %}
  {% elif grains.os_family == 'Windows' %}
    {% set snapd_supported = False %}
  {% endif %}

  {% if snapd_install_needed %}
snapd:
    {% if grains.os_family == 'Suse' %}
  cmd.run:
    - name: |
                sudo=$(command -v sudo)
                $sudo zypper addrepo --refresh {{ suse_repo }} snappy
                $sudo zypper --gpg-auto-import-keys refresh
                $sudo zypper dup --from snappy
                $sudo zypper install -y snapd
                $sudo systemctl enable snapd
                $sudo systemctl start snapd
                sleep 10
    {% else %}
  pkg.installed:
    - name:     snapd
      {% if grains.cfg_snapd.snapd.version is defined %}
    - version:  {{ grains.cfg_snapd.snapd.version }}
      {% endif %}
      {% if grains.os_family == 'RedHat' %}
  cmd.run:
    - name: |
                sudo=$(command -v sudo)
                sudo ln -s /var/lib/snapd/snap /snap
                sudo systemctl restart snapd.service
                sleep 20
      {% endif %}
    {% endif %}
  {% endif %}

  {% if snapd_supported %}
    {% if grains.cfg_snapd.debug.enable %}
snapd-version:
  cmd.run:
    - name: snap version
    {% endif %}
  {% endif %}
{% endif %}
