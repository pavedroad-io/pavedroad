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

roadctl:
  {# roadctl make file use which, missing in Suse #}
  {% if grains.os_family == 'Suse' %}
  pkg.installed:
    - unless:   command -v which
    - name:     which
  {% endif %}
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

  {# roadctl only seems to support bash completion #}
  {% if completion and 'bash' in completion %}
    {% set roadctl_bash_comp_file = 'roadctlBashCompletion.sh' %}
    {% set bash_comp_file = pillar.directories.completions.bash + '/roadctl' %}
roadctl-bash-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.bash }}
                {{ roadctl_path }}{{ roadctl_pkg_name }} completion
                mv {{ roadctl_bash_comp_file }} {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ roadctl_path }}{{ roadctl_pkg_name }}
  {% endif %}

  {% if grains.cfg_roadctl.debug.enable %}
roadctl-version:
  cmd.run:
    - name:     {{ roadctl_path }}{{ roadctl_pkg_name }} version
  {% endif %}
{% endif %}
