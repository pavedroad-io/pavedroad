# Install microk8s

include:
  - multipass
  - snapd

{% set installs = grains.cfg_microk8s.installs %}

{% if installs and 'microk8s' in installs %}
  {% set microk8s_vm_install = False %}

  {% if grains.os_family == 'MacOS' %}
    {% set microk8s_vm_install = True %}
  {% elif grains.os_family == 'Windows' %}
    {% set microk8s_vm_install = True %}
  {% endif %}

  {% if grains.os_family == 'MacOS' %}
multipass-vm-launch:
  cmd.run:
    - require:
      - sls:    multipass
    - name: |
                multipass delete microk8s-vm
                multipass purge
                multipass launch --name microk8s-vm --mem 4G --disk 40G
multipass-vm-running:
  cmd.run:
    - name:     until multipass exec microk8s-vm -- uname -a; do sleep 1; done
    - timeout:  10
microk8s-install:
  cmd.run:
    - name:     until multipass exec microk8s-vm -- sudo snap install microk8s --classic; do sleep 10; done
    - timeout:  360
microk8s-post-install:
  cmd.run:
    - name: |
                multipass exec microk8s-vm -- /snap/bin/microk8s.inspect
                multipass exec microk8s-vm -- sudo iptables -P FORWARD ACCEPT
  {% else %}
microk8s:
  cmd.run:
    - require:
      - sls:    snapd
    - name:     $(command -v sudo) snap install microk8s --classic
  {% endif %}
{% endif %}

{% if grains.cfg_microk8s.debug.enable %}
  {% if microk8s_vm_install %}
microk8s-version:
  cmd.run:
    - name: multipass exec microk8s-vm -- snap list | grep microk8s
microk8s-status:
  cmd.run:
    - name: |
            multipass exec microk8s-vm -- /snap/bin/microk8s.start
            multipass exec microk8s-vm -- /snap/bin/microk8s.status
            multipass exec microk8s-vm -- /snap/bin/microk8s.stop
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
