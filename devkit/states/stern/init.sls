# Install stern

{% set installs = grains.cfg_stern.installs %}
{% set completion = grains.cfg_stern.completion %}

{% if installs and 'stern' in installs %}
  {% set stern_pkg_name = 'stern' %}
  {% set stern_binary_install = True %}

  {% if stern_binary_install %}
    {% set stern_prefix = 'https://github.com/wercker/stern/releases/download/' %}
    {% if grains.cfg_stern.stern.version is defined %}
      {% set stern_version = grains.cfg_stern.stern.version %}
    {% else %}
      {% set stern_version = '1.11.0' %}
    {% endif %}
    {% if grains.os_family == 'MacOS' %}
      {% set stern_file = '/stern_darwin_amd64' %}
    {% else %}
      {% set stern_file = '/stern_linux_amd64' %}
    {% endif %}
    {% set stern_url = stern_prefix + stern_version + stern_file %}
    {% set stern_bin = '/usr/local/bin' %}
  {% else %}
    {% set stern_url = 'https://github.com/wercker/stern.git' %}
    {% set stern_src = grains.homedir + '/go/src' %}
    {% set stern_bin = grains.homedir + '/go/bin' %}
  {% endif %}

include:
  - golang

stern:
  {% if stern_binary_install %}
  file.managed:
    - name:        {{ stern_bin }}/{{ stern_pkg_name }}
    - source:      {{ stern_url }}
    - makedirs:    True
    - skip_verify: True
    - mode:        755
    - replace:     False
  {% else %}
  {# stern build instructions do not work with latest go version #}
  git.latest:
    - unless:      command -v {{ stern_pkg_name }}
    - name:        {{ stern_url }}
    - rev:         master
    - target:      {{ stern_src }}/{{ stern_pkg_name }}
    - force_clone: True
  cmd.run:
    - require:
      - git:    stern
    - cwd:      {{ stern_src }}/{{ stern_pkg_name }}
    - umask:    022
    - name:     |
                . {{grains.homedir}}/.pr_go_env
                govendor sync
                go install
  {% endif %}

  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/stern' %}
stern-bash-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.bash }}
                {{ stern_bin }}/stern --completion=bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ stern_bin }}/stern
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_stern' %}
stern-zsh-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.zsh }}
                {{ stern_bin }}/stern --completion=zsh > {{ zsh_comp_file }}
    - unless:   test -e {{ zsh_comp_file }}
    - onlyif:   test -x {{ stern_bin }}/stern
    {% endif %}
  {% endif %}

  {% if grains.cfg_stern.debug.enable %}
stern-version:
  cmd.run:
    - name:     {{ stern_bin }}/{{ stern_pkg_name }} --version
  {% endif %}
{% endif %}
