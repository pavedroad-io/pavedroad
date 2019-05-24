# Install docker
#
# Do not install docker in a docker container

{% if grains.docker %}
  {% set installs = False %}
{% else %}
  {% set installs = grains.cfg_docker.installs %}
{% endif %}

{% if installs and 'docker' in installs %}
  {% set docker_pkg_name = 'docker' %}
  {% set docker_alt_install = False %}

  {% if grains.os_family == 'Debian' %}
    {% set docker_pkg_name = 'docker.io' %}
  {% endif %}

docker:
  {% if docker_alt_install %}
  cmd.run:
    - unless:   command -v docker
    - name: |
                curl -fsSL https://get.docker.com -o get-docker.sh
                sh get-docker.sh
  {% else %}
  pkg.installed:
    - unless:   command -v docker
    - name:     {{ docker_pkg_name }}
    {% if grains.cfg_docker.docker.version is defined %}
    - version:  {{ grains.cfg_docker.docker.version }}
    {% endif %}
  {% endif %}
  {% if not grains.os_family == 'MacOS' %}
  group.present:
    - name:     docker
    - addusers:
      -         {{ grains.username }}
  service.running:
    - name:     docker
    - reload:   True
    - init_delay: 10
    - enable:   True
    - require:
      - pkg:    docker
  {% endif %}
{% endif %}

{% if installs and 'compose' in installs %}
  {% set compose_pkg_name = 'docker-compose' %}

compose:
  pkg.installed:
    - unless:   command -v docker-compose
    - name:     {{ compose_pkg_name }}
  {% if grains.cfg_docker.compose.version is defined %}
    - version:  {{ grains.cfg_docker.compose.version }}
  {% endif %}
{% endif %}

{% if installs and grains.cfg_docker.debug.enable %}
docker-files:
  cmd.run:
  {% if grains.os_family == 'MacOS' %}
    - name:     ls -l /usr/local/bin/docker*
  {% else %}
    - name:     ls -l /usr/bin/docker*
  {% endif %}
docker-version:
  cmd.run:
    - name:     docker --version
compose-version:
  cmd.run:
    - name:     docker-compose --version
  {% if not grains.os_family == 'MacOS' %}
docker-group:
  cmd.run:
    - name:     grep docker /etc/group
  {% endif %}
docker-test:
  cmd.run:
    - name:     docker run hello-world
{% endif %}
