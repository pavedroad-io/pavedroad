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
  {% set docker_bin_name = 'docker' %}
  {% set docker_alt_install = False %}
  {% set docker_ce_repo_install = False %}
  {% set docker_opt_nobest = False %}
  {% set docker_service = True %}
  {% set docker_group = True %}
  {% set docker_path = '/usr/bin' %}
  {% set compose_pip_install = False %}
  {% set compose_binary_install = False %}
  {% set compose_pkg_name = 'docker-compose' %}
  {% set compose_bin_name = 'docker-compose' %}
  {% set compose_path = '/usr/bin' %}

  {% if grains.os_family == 'Debian' %}
    {% set docker_pkg_name = 'docker.io' %}
  {% elif grains.os_family == 'RedHat' %}
    {% if grains.os == 'CentOS' and grains.osmajorrelease >= 8 %}
      {% set docker_ce_repo_install = True %}
      {% set docker_repo_os = 'centos/7' %}
      {% set docker_opt_nobest = True %}
      {% set compose_pip_install = True %}
    {# docker fails in in Fedora in later versions due to cgroups / nftables #}
    {# Substituting pod man which is cli compatible with docker for now #}
    {# Leaving docker-compose for now as podman-compose is not ready #}
    {% elif grains.os == 'Fedora' and grains.osmajorrelease >= 31 %}
      {% set docker_pkg_name = 'podman' %}
      {% set docker_bin_name = 'podman' %}
      {% set docker_service = False %}
      {% set docker_group = False %}
      {% set compose_pip_install = True %}
    {% elif grains.os == 'Fedora' and grains.osmajorrelease <= 30 %}
      {% set docker_ce_repo_install = True %}
      {% set docker_repo_os = 'fedora/' + grains.osmajorrelease|string %}
      {% set compose_pip_install = True %}
    {% endif %}
  {% elif grains.os_family == 'MacOS' %}
    {% set docker_app = '/Applications/Docker.app' %}
    {% set docker_path = docker_app + '/Contents/Resources/bin' %}
    {% set compose_path = docker_path + '/docker-compose' %}
  {% endif %}

  {% if docker_ce_repo_install %}
    {% set docker_repo_url = 'https://download.docker.com/linux/' %}
    {% set docker_repo_url = docker_repo_url + docker_repo_os %}
    {% set docker_repo_url = docker_repo_url + '/x86_64/stable' %}
  {% endif %}
  {% if docker_alt_install %}
    {% set docker_temp= '/tmp/docker' %}
    {% set docker_script = 'install.sh' %}
  {% endif %}
  {% if compose_pip_install %}
    {% set compose_path = '/usr/local/bin' %}
  {% endif %}
  {% if compose_binary_install %}
    {% set compose_path = '/usr/local/bin' %}
    {% set compose_bin_path = compose_path + '/' + compose_bin_name %}
    {% set compose_bin_url = 'https://github.com/docker/compose/releases/download/' %}
    {% set compose_bin_url = compose_bin_url + grains.cfg_docker.compose.version %}
    {% set compose_bin_url = compose_bin_url + '/' + compose_pkg_name %}
    {% set compose_bin_url = compose_bin_url + '-' + salt.cmd.run('uname -s') %}
    {% set compose_bin_url = compose_bin_url + '-' + salt.cmd.run('uname -m') %}
  {% endif %}

{# MacOS - brew cask installs /Applications/Docker.app (client and server)
   CLI commands and launchctl are set up first time Docker.app is opened #}

  {% if compose_pip_install %}
include:
  - pip3
  {% endif %}

docker:
  {% if grains.os_family == 'MacOS' %}
  cmd.run:
    - unless:   test -d  {{ docker_app }}
    - name:     brew cask install docker
  {% elif docker_alt_install %}
docker-script:
  file.managed:
    - unless:      command -v {{ docker_bin_name }}
    - name:        {{ docker_temp }}/{{ docker_script }}
    - source:      https://get.docker.com
    - makedirs:    True
    - skip_verify: True
    - replace:     False
  cmd.run:
    - unless:   command -v {{ docker_bin_name }}
    - name:     sh {{ docker_script }}
    - cwd:      {{ docker_temp }}
    - require:
      - file:   docker-script
  {% else %}
    {% if docker_ce_repo_install %}
  pkgrepo.managed:
    - name:      docker-ce-stable
    - humanname: Docker CE Stable - x86_64
    - enabled:   True
    - refresh:   True
    - baseurl:   {{ docker_repo_url }}
    - gpgcheck:  True
    - gpgkey:    https://download.docker.com/linux/centos/gpg
    {% endif %}
  pkg.installed:
    - unless:   command -v {{ docker_bin_name }}
    {% if docker_ce_repo_install %}
    - pkgs:
      -         containerd.io
      -         docker-ce
      -         docker-ce-cli
    {% else %}
    - name:     {{ docker_pkg_name }}
    {% endif %}
    {% if grains.cfg_docker.docker.version is defined %}
    - version:  {{ grains.cfg_docker.docker.version }}
    {% endif %}
    {% if docker_opt_nobest %}
    - setopt:
      - best=False
    {% endif %}
  {% endif %}

  {% if not grains.os_family == 'MacOS' %}
    {% if docker_group %}
  group.present:
    - name:     {{ docker_bin_name }}
    - addusers:
      -         {{ grains.realuser }}
    {% endif %}
    {% if docker_service %}
  service.running:
    - name:       {{ docker_bin_name }}
    - reload:     True
    - init_delay: 10
    - enable:     True
    - require:
      - pkg:      docker
    {% endif %}
  {% endif %}
{% endif %}

{% if installs and 'compose' in installs %}

# MacOS - brew cask install docker also installs compose

  {% if not grains.os_family == 'MacOS' %}
compose:
    {% if compose_pip_install %}
  pip.installed:
    - unless:   command -v {{ compose_bin_name }}
    - name:     {{ compose_pkg_name }}
    {% elif compose_binary_install %}
  file.managed:
    - unless:   command -v {{ compose_bin_name }}
    - name:     {{ compose_bin_path }}
    - source:   {{ compose_bin_url }}
    - makedirs: True
    - mode:     755
    - skip_verify: True
    - replace:  False
    {% else %}
  pkg.installed:
    - unless:   command -v {{ compose_bin_name }}
    - name:     {{ compose_pkg_name }}
      {% if grains.cfg_docker.compose.version is defined %}
    - version:  {{ grains.cfg_docker.compose.version }}
      {% endif %}
    {% endif %}
  {% endif %}
{% endif %}

# MacOS - brew cask install docker does not install completions

{% if completion %}
  {% if grains.os_family == 'MacOS' %}
mac-docker-completion:
  pkg.installed:
    - name:     docker-completion
mac-compose-completion:
  pkg.installed:
    - name:     docker-compose-completion
  {% else %}
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
{% endif %}

# MacOS - docker links in /usr/local/bin are created when the Docker app is first run

{% if installs and grains.cfg_docker.debug.enable %}
  {% if installs and 'docker' in installs %}
docker-version:
  cmd.run:
    - name:     {{ docker_path }}/{{ docker_bin_name }} --version
    {% if not grains.os_family == 'MacOS' %}
docker-test:
  cmd.run:
    - name:     {{ docker_path }}/{{ docker_bin_name }} run hello-world
      {% if docker_group %}
docker-group:
  cmd.run:
    - name:     grep {{ docker_bin_name }} /etc/group
      {% endif %}
    {% endif %}
docker-files:
  cmd.run:
    - name:     ls -ld {{ docker_path }}/{{ docker_bin_name }}*
  {% endif %}
  {% if installs and 'compose' in installs %}
compose-version:
  cmd.run:
    - name:     {{ compose_path }}/{{ compose_bin_name }} --version
  {% endif %}
{% endif %}
