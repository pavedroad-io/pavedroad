# Install roadctl

{% set installs = grains.cfg_roadctl.installs %}
{% set completion = grains.cfg_roadctl.completion %}

{% if installs and 'roadctl' in installs %}
  {% set roadctl_pkg_name = 'roadctl' %}
  {% set roadctl_url = ' https://github.com/pavedroad-io/roadctl.git' %}
  {% set roadctl_tmp = '/tmp/' + roadctl_pkg_name %}
  {% set roadctl_path = '/usr/local/bin/' %}

{# Get development tools to run make #}
include:
  - golang
  {% if grains.os_family == 'Debian' %}
  - debian
  {% elif grains.os_family == 'RedHat' %}
  - redhat
  {% elif grains.os_family == 'MacOS' %}
  - macos
  {% endif %}
  {% if completion and 'bash' in completion %}
  - bash
  {% endif %}

roadctl:
  git.latest:
    - unless:   command -v {{ roadctl_pkg_name }}
    - name:     {{ roadctl_url }}
    - rev:      master
    - target:   {{ roadctl_tmp }}
  cmd.run:
    - require:
      - git:    roadctl
    - cwd:      {{ roadctl_tmp }}/src/{{ roadctl_pkg_name }}
    - umask:    022
    - name:     |
                . $HOME/.pr_go_env
                make all
  file.managed:
    - name:     {{ roadctl_path }}{{ roadctl_pkg_name }}
    {# Why is this not in /bin instead of /src/roadctl? #}
    - source:   {{ roadctl_tmp }}/src/roadctl/{{ roadctl_pkg_name }}
    - makedirs: True
    - skip_verify: True
    - mode:     755

  {% if completion and 'bash' in completion %}
    {% if grains.os_family == 'MacOS' %}
      {% set bash_comp_dir = '/usr/local/etc/bash_completion.d/' %}
    {% else %}
      {% set bash_comp_dir = '/usr/share/bash-completion/completions/' %}
    {% endif %}
    {% set roadctl_bash_comp_file = 'roadctlBashCompletion.sh' %}
    {% set bash_comp_file = bash_comp_dir + roadctl_pkg_name %}
roadctl-bash-completion:
  cmd.run:
    - name:     |
                {{ roadctl_path }}{{ roadctl_pkg_name }} completion
                mv {{ roadctl_bash_comp_file }} {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ roadctl_path }}{{ roadctl_pkg_name }}
    - require:
      - sls:    bash
  {% endif %}

  {% if grains.cfg_roadctl.debug.enable %}
roadctl-version:
  cmd.run:
    - name:     {{ roadctl_path }}{{ roadctl_pkg_name }} version
  {% endif %}
{% endif %}
