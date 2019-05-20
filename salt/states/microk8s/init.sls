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

microk8s:
  cmd.run:
  {% if grains.os_family == 'MacOS' %}
    - require:
      - sls:    multipass
    - name: |
                multipass launch --name microk8s-vm --mem 4G --disk 40G
                sleep 10
                multipass exec microk8s-vm -- sudo snap install microk8s --classic
                sleep 10
                multipass exec microk8s-vm -- /snap/bin/microk8s.inspect
                multipass exec microk8s-vm -- sudo iptables -P FORWARD ACCEPT
  {% else %}
    - require:
      - sls:    snapd
    - name:     $(command -v sudo) snap install microk8s --classic
  {% endif %}
{% endif %}

{% if grains.cfg_microk8s.debug.enable %}
  {% if microk8s_vm_install %}
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
