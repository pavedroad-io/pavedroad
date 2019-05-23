# Install microk8s

{% if grains.docker %}
  {% set installs = False %}
{% else %}
  {% set installs = grains.cfg_microk8s.installs %}
{% endif %}

{% if installs and 'microk8s' in installs %}
  {% set snapd_required = True %}
  {% set multipass_required = False %}

  {% if grains.os_family == 'MacOS' %}
    {% set multipass_required = True %}
  {% elif grains.os_family == 'Windows' %}
    {% set multipass_required = True %}
  {% endif %}

include:
  {% if multipass_required %}
  - multipass
  {% elif snapd_required %}
  - snapd
  {% endif %}

  {% if multipass_required %}
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
  {% elif snapd_required %}
microk8s:
  cmd.run:
    - require:
      - sls:    snapd
    - unless:   snap list | grep microk8s
    - name:     $(command -v sudo) snap install microk8s --classic
  {% endif %}

  {% if grains.cfg_microk8s.debug.enable %}
    {% if multipass_required %}
microk8s-version:
  cmd.run:
    - name:     multipass exec microk8s-vm -- snap list | grep microk8s
microk8s-status:
  cmd.run:
    - name: |
                multipass exec microk8s-vm -- /snap/bin/microk8s.start
                multipass exec microk8s-vm -- /snap/bin/microk8s.status
                multipass exec microk8s-vm -- /snap/bin/microk8s.stop
  {% elif snapd_required %}
microk8s-files:
  cmd.run:
    - name: ls -l /snap/bin/microk8s*
microk8s-version:
  cmd.run:
    - name: snap list | grep microk8s
microk8s-test:
  cmd.run:
    - name: |
                sudo=$(command -v sudo)
                $sudo /snap/bin/microk8s.start
                $sudo /snap/bin/microk8s.status
                $sudo /snap/bin/microk8s.stop
    {% endif %}
  {% endif %}
{% endif %}
