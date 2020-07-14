# Install direnv

{% set installs = grains.cfg_direnv.installs %}

{% if installs and 'direnv' in installs %}
  {% set direnv_pkg_name = 'direnv' %}
  {% set direnv_bin_name = 'direnv' %}
  {% set direnv_binary_install = False %}
  {% set direnv_path = '/usr/bin' %}
  {% if grains.os == 'CentOS' %}
    {% set direnv_binary_install = True %}
    {% set direnv_path = '/usr/local/bin' %}
  {% elif grains.os_family == 'MacOS' %}
    {% set direnv_path = '/usr/local/bin' %}
  {% endif %}

direnv:
  {% if direnv_binary_install %}
  file.managed:
    - unless:   command -v {{ direnv_bin_name }}
    - name:     {{ direnv_path }}/{{ direnv_pkg_name }}
    - source:   https://github.com/direnv/direnv/releases/download/v2.20.0/direnv.linux-386
    - makedirs: True
    - mode:     755
    - skip_verify: True
    - replace:  False
  {% else %}
  pkg.installed:
    - unless:   command -v {{ direnv_bin_name }}
    - name:     {{ direnv_pkg_name }}
    {% if grains.cfg_direnv.direnv.version is defined %}
    - version:  {{ grains.cfg_direnv.direnv.version }}
    {% endif %}
  {% endif %}
direnv-append-pr_bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     eval "$(direnv hook bash)"
direnv-append-pr_zshrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     eval "$(direnv hook zsh)"

  {% if grains.cfg_direnv.debug.enable %}
direnv-version:
  cmd.run:
    - name:     {{ direnv_path }}/{{ direnv_bin_name }} version
  {% endif %}

{% endif %}
