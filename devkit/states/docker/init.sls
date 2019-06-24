# Install docker

# Do not install docker in a docker container

{% if grains.docker %}
  {% set installs = False %}
  {% set completion = False %}
{% else %}
  {% set installs = grains.cfg_docker.installs %}
  {% set completion = grains.cfg_docker.completion %}
{% endif %}

{% if installs and 'docker' in installs %}
  {% set docker_pkg_name = 'docker' %}
  {% set docker_alt_install = False %}

  {% if grains.os_family == 'Debian' %}
    {% set docker_pkg_name = 'docker.io' %}
  {% endif %}

  {% if completion and 'bash' in completion %}
include:
  - bash
  {% endif %}

# MacOS - brew cask installs /Applications/Docker.app (client and server)

docker:
  {% if grains.os_family == 'MacOS' %}
  cmd.run:
    - unless:   test -d /Applications/Docker.app
    - name:     brew cask install docker
  {% elif docker_alt_install %}
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
      -         {{ grains.realuser }}
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

# MacOS - brew cask install docker also installs compose

  {% if not grains.os_family == 'MacOS' %}
compose:
  pkg.installed:
    - unless:   command -v docker-compose
    - name:     {{ compose_pkg_name }}
    {% if grains.cfg_docker.compose.version is defined %}
    - version:  {{ grains.cfg_docker.compose.version }}
    {% endif %}
  {% endif %}
{% endif %}

# MacOS - brew cask install docker does not install completions

{% if completion and 'bash' in completion %}
  {% set docker_prefix = 'https://raw.githubusercontent.com/docker' %}
  {% set docker_content = '/cli/master/contrib/completion/bash/docker' %}
  {% set docker_comp_url = docker_prefix + docker_content %}
  {# set compose_vers = salt.cmd.run('docker-compose version --short') #}
  {% set compose_vers = '1.18.0' %}
  {% set compose_content = '/contrib/completion/bash/docker-compose' %}
  {% set compose_comp_url = docker_prefix + '/compose/' + compose_vers + compose_content %}
  {% if grains.os_family == 'MacOS' %}
    {% set bash_comp_dir = '/usr/local/etc/bash_completion.d' %}
  {% else %}
    {% set bash_comp_dir = '/usr/share/bash-completion/completions' %}
  {% endif %}

docker-bash-completion:
  file.managed:
    - name:     {{ bash_comp_dir }}/docker
    - source:   {{ docker_comp_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
    - require:
      - sls:    bash
compose-bash-completion:
  file.managed:
    - name:     {{ bash_comp_dir }}/docker-compose
    - source:   {{ compose_comp_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
    - require:
      - sls:    bash
{% endif %}

# MacOS - docker links in /usr/local/bin are created when the Docker app is first run

{% if installs and grains.cfg_docker.debug.enable %}
  {% if not grains.os_family == 'MacOS' %}
docker-version:
  cmd.run:
    - name:     docker --version
docker-group:
  cmd.run:
    - name:     grep docker /etc/group
docker-files:
  cmd.run:
    - name:     ls -l /usr/bin/docker*
docker-test:
  cmd.run:
    - name:     docker run hello-world
compose-version:
  cmd.run:
    - name:     docker-compose --version
  {% endif %}
{% endif %}
