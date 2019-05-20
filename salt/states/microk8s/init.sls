# Install microk8s

{% set installs = grains.cfg_microk8s.installs %}

{% if installs and 'microk8s' in installs %}
  {% set microk8s_vm_install = False %}

  {% if grains.os_family == 'MacOS' %}
    {% set microk8s_vm_install = True %}
  {% elif grains.os_family == 'Windows' %}
    {% set microk8s_vm_install = True %}
  {% elif grains.os_family == 'Suse' %}
    {% set suse_path = 'https://download.opensuse.org/repositories/system:/snappy/' %}
    {% set suse_repo = suse_path + 'openSUSE_Leap_' + grains.osrelease %}
  {% endif %}

  {% if grains.os_family == 'MacOS' %}
multipass:
  cmd.run:
    - name:     brew cask install multipass
  {% elif grains.os_family == 'RedHat' %}
snap:
  pkg.installed:
    - name:     snapd
  cmd.run:
    - name: |
                $(command -v sudo) ln -s /var/lib/snapd/snap /snap
                sleep 20
  {% elif grains.os_family == 'Suse' %}
snap:
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
  {% endif %}

microk8s:
  cmd.run:
  {% if grains.os_family == 'MacOS' %}
    - name: |
                multipass launch --name microk8s-vm --mem 4G --disk 40G
                sleep 10
                multipass exec microk8s-vm -- sudo snap install microk8s --classic
                sleep 10
                multipass exec microk8s-vm -- /snap/bin/microk8s.inspect
                multipass exec microk8s-vm -- sudo iptables -P FORWARD ACCEPT
  {% else %}
    - name:     $(command -v sudo) snap install microk8s --classic
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
    - name: multipass exec microk8s-vm -- /snap/bin/microk8s.status
  {% else %}
microk8s-files:
  cmd.run:
    - name: ls -l /snap/bin/microk8s*
microk8s-version:
  cmd.run:
    - name: snap list | grep microk8s
microk8s-test:
  cmd.run:
    - name: |
            /snap/bin/microk8s.start
            /snap/bin/microk8s.status
            /snap/bin/microk8s.stop
  {% endif %}
{% endif %}
