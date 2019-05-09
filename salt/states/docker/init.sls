# Install docker

{% set installs = grains.cfg_docker.installs %}

{% if installs and 'docker' in installs %}
  {% set docker_pkg_name = 'docker' %}

  {% if grains.os_family == 'Debian' %}
    {% set docker_pkg_name = 'docker.io' %}
  {% elif grains.os_family == 'RedHat' %}
  {% elif grains.os_family == 'Suse' %}
  {% elif grains.os_family == 'MacOS' %}
  {% elif grains.os_family == 'Windows' %}
  {% endif %}

docker:
  pkg.installed:
    - name:     {{ docker_pkg_name }}
    - version:  {{ grains.cfg_docker.docker.version }}
{% endif %}

{% if installs and 'compose' in installs %}
  {% set compose_pkg_name = 'docker-compose' %}

  {% if grains.os_family == 'Debian' %}
  {% elif grains.os_family == 'RedHat' %}
  {% elif grains.os_family == 'Suse' %}
  {% elif grains.os_family == 'MacOS' %}
  {% elif grains.os_family == 'Windows' %}
  {% endif %}

compose:
  pkg.installed:
    - name:     {{ compose_pkg_name }}
    - version:  {{ grains.cfg_docker.compose.version }}
{% endif %}

files:
  cmd.run:
    - name: ls -l /usr/bin/docker*
docker-version:
  cmd.run:
    - name: docker --version
compose-version:
  cmd.run:
    - name: docker-compose --version
