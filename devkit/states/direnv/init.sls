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

  {% if grains.cfg_direnv.direnv.version is defined and
    grains.cfg_direnv.direnv.version != 'latest' %}
    {% set direnv_version = grains.cfg_direnv.direnv.version %}
  {% else %}
    {% set direnv_version = 'latest' %}
  {% endif %}

  {% if direnv_binary_install %}
    {% if direnv_version == 'latest' %}
      {% set direnv_temp = '/tmp/direnv' %}
      {% set direnv_script = 'install.sh' %}
      {% set direnv_url = 'https://direnv.net/install.sh' %}
    {% else %}
      {% set direnv_url = 'https://github.com/direnv/direnv/releases/download/v' %}
      {% set direnv_url = direnv_url + direnv_version + '/direnv.linux-386' %}
    {% endif %}
  {% endif %}

  {% if direnv_binary_install %}
    {% if direnv_version == 'latest' %}
direnv-script:
  file.managed:
    - unless:      command -v {{ direnv_bin_name }}
    - name:        {{ direnv_temp }}/{{ direnv_script }}
    - source:      {{ direnv_url }}
    - makedirs:    True
    - skip_verify: True
  cmd.run:
    - unless:   command -v {{ direnv_bin_name }}
    - name:     PATH=/usr/local/bin:$PATH bash {{ direnv_script }}
    - cwd:      {{ direnv_temp }}
    - require:
      - file:   direnv-script
    {% else %}
direnv-binary:
  file.managed:
    - unless:      command -v {{ direnv_bin_name }}
    - name:        {{ direnv_path }}/{{ direnv_pkg_name }}
    - source:      {{ direnv_url }}
    - makedirs:    True
    - mode:        755
    - skip_verify: True
    - replace:     False
    {% endif %}
  {% else %}
direnv-package:
  pkg.installed:
    - unless:   command -v {{ direnv_bin_name }}
    - name:     {{ direnv_pkg_name }}
    - version:  {{ direnv_version }}
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
