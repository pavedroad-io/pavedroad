# Install microk8s

{% set installs = grains.cfg_microk8s.installs %}

{% if installs and 'microk8s' in installs %}
  {% set microk8s_pkg_name = 'microk8s' %}
  {% set microk8s_vm_install = False %}
  {% set microk8s_snap_install= False %}
  {% set multipass_install = False %}
  {% set multipass_brew_install = False %}

  {% if grains.os_family == 'MacOS' %}
    {% set microk8s_vm_install = True %}
    {% set multipass_install = True %}
    {% set multipass_brew_install = True %}
  {% elif grains.os_family == 'Debian' %}
    {% set microk8s_snap_install= True %}
  {% elif grains.os_family == 'Windows' %}
    {% set microk8s_vm_install = True %}
  {% endif %}

{% if multipass_install %}
multipass:
  {% if multipass_brew_install %}
  cmd.run:
    - name: brew cask install multipass
  {% else %}
  pkg.installed:
    - name:     {{ multipass_pkg_name }}
    {% if grains.cfg_microk8s.multipass.version is defined %}
    - version:  {{ grains.cfg_microk8s.multipass.version }}
    {% endif %}
  {% endif %}
{% endif %}

microk8s:
  {% if microk8s_vm_install %}
  cmd.run:
    - name: |
                multipass launch --name microk8s-vm --mem 4G --disk 40G
                sleep 10
                multipass exec microk8s-vm -- sudo snap install microk8s --classic
                multipass exec microk8s-vm -- /snap/bin/microk8s.inspect
                multipass exec microk8s-vm -- sudo iptables -P FORWARD ACCEPT
  {% elif microk8s_snap_install %}
  cmd.run:
    - name: |
                snap install microk8s --classic
  {% else %}
  pkg.installed:
    - name:     {{ microk8s_pkg_name }}
    {% if grains.cfg_microk8s.microk8s.version is defined %}
    - version:  {{ grains.cfg_microk8s.microk8s.version }}
    {% endif %}
  {% endif %}
{% endif %}

{% if grains.cfg_microk8s.debug.enable %}
  {% if microk8s_vm_install %}
multipass-version:
  cmd.run:
    - name: multipass --version
microk8s-version:
  cmd.run:
    - name: multipass exec microk8s-vm -- snap list
microk8s-status:
  cmd.run:
    - name: |
            multipass exec microk8s-vm -- /snap/bin/microk8s.status
  {% else %}
microk8s-files:
  cmd.run:
    - name: ls -l /snap/bin/microk8s*
microk8s-test:
  cmd.run:
    - name: |
            microk8s.start
            microk8s.status
            microk8s.stop
  {% endif %}
{% endif %}
