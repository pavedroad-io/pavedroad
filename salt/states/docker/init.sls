# Install docker

{% set installs = grains.cfg_docker.installs %}

{% if installs and 'docker' in installs %}
docker:
  pkg.installed:
    - name:     docker
  {% if grains.cfg_docker.docker.version is defined %}
    - version:  {{ grains.cfg_docker.docker.version }}
  {% endif %}
  {% if grains.cfg_docker.docker.service %}
  service.running:
    - name:     docker
    - enable:   True
    - require:
      - pkg:    docker
  {% endif %}
{% endif %}
