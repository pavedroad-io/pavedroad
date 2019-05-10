# Install docker

{% set installs = grains.cfg_docker.installs %}

{% if installs and 'docker' in installs %}
  {% set docker_pkg_name = 'docker' %}
  {% set docker_alt_install = False %}

  {% if grains.os_family == 'Debian' %}
    {% set docker_pkg_name = 'docker.io' %}
  {% elif grains.os_family == 'RedHat' %}
    {% set docker_alt_install = True %}
  {% endif %}

docker:
  {% if docker_alt_install %}
  cmd.run:
    - name: |
                curl -fsSL https://get.docker.com -o get-docker.sh
                sh get-docker.sh
  {% else %}
  pkg.installed:
    - name:     {{ docker_pkg_name }}
    {% if grains.cfg_docker.docker.version is defined %}
    - version:  {{ grains.cfg_docker.docker.version }}
    {% endif %}
  {% endif %}

  group.present:
    - name:     docker
    - addusers:
      -         {{ grains.username }}
{% endif %}

{% if installs and 'compose' in installs %}
  {% set compose_pkg_name = 'docker-compose' %}

compose:
  pkg.installed:
    - name:     {{ compose_pkg_name }}
  {% if grains.cfg_docker.compose.version is defined %}
    - version:  {{ grains.cfg_docker.compose.version }}
  {% endif %}
{% endif %}

{% if grains.cfg_docker.debug.enable %}
docker-files:
  cmd.run:
    - name: ls -l /usr/bin/docker*
docker-version:
  cmd.run:
    - name: docker --version
compose-version:
  cmd.run:
    - name: docker-compose --version
docker-group:
  cmd.run:
    - name: grep docker /etc/group
docker-test:
  cmd.run:
    - name: DOCKER_HOST={{ grains.cfg_docker.debug.host }} docker run hello-world
{% endif %}
