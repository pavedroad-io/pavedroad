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

{% if completion %}
  {% set docker_prefix = 'https://raw.githubusercontent.com/docker/' %}
  {% set docker_content = 'cli/master/contrib/completion/' %}
  {# set compose_vers = salt.cmd.run('docker-compose version --short') #}
  {% set compose_vers = '1.18.0' %}
  {% set compose_content = 'compose/' + compose_vers + '/contrib/completion/' %}
  {% if 'bash' in completion %}
    {% set docker_bash_url = docker_prefix + docker_content + 'bash/docker' %}
    {% set compose_bash_url = docker_prefix + compose_content + 'bash/docker-compose' %}

docker-bash-completion:
  file.managed:
    - name:     {{ pillar.directories.completions.bash }}/docker
    - source:   {{ docker_bash_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
compose-bash-completion:
  file.managed:
    - name:     {{ pillar.directories.completions.bash }}/docker-compose
    - source:   {{ compose_bash_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
  {% endif %}

  {% if 'zsh' in completion %}
    {% set docker_zsh_url = docker_prefix + docker_content + 'zsh/_docker' %}
    {% set compose_zsh_url = docker_prefix + compose_content + 'zsh/_docker-compose' %}

docker-zsh-completion:
  file.managed:
    - name:     {{ pillar.directories.completions.zsh }}/_docker
    - source:   {{ docker_zsh_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
compose-zsh-completion:
  file.managed:
    - name:     {{ pillar.directories.completions.zsh }}/_docker-compose
    - source:   {{ compose_zsh_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
  {% endif %}
{% endif %}

# MacOS - docker links in /usr/local/bin are created when the Docker app is first run

{% if installs and grains.cfg_docker.debug.enable %}
docker-version:
  cmd.run:
    - name:     docker --version
compose-version:
  cmd.run:
    - name:     docker-compose --version
docker-test:
  cmd.run:
    - name:     docker run hello-world
  {% if not grains.os_family == 'MacOS' %}
docker-group:
  cmd.run:
    - name:     grep docker /etc/group
docker-files:
  cmd.run:
    - name:     ls -l /usr/bin/docker*
  {% endif %}
{% endif %}
