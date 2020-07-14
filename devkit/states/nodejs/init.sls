# Install nodejs (node and npm)

# npm completion: see https://docs.npmjs.com/cli-commands/completion.html
# Cannot get either bash or zsh completion to work using this
# brew installs the bash completion file on MacOS that npm generates

{% set installs = grains.cfg_nodejs.installs %}

{% if installs and 'nodejs' in installs %}
  {% set npm_pkg_name = 'npm' %}
  {% set node_bin_name = 'node' %}
  {% set npm_bin_name = 'npm' %}
  {% set nodejs_install = False %}
  {% set nodejs_pkg_name = 'nodejs' %}
  {% set nodejs_bin_name = 'node' %}
  {% set package_bin_path = '/usr/bin/' %}
  {% set install_bin_path = '/usr/bin/' %}

  {% if grains.cfg_nodejs.npm.version is defined and
    grains.cfg_nodejs.npm.version == 'latest' %}
    {% set update_npm = True %}
  {% endif %}
  {% if grains.cfg_nodejs.nodejs.version is defined and
    grains.cfg_nodejs.nodejs.version == 'latest' %}
    {% set update_nodejs = True %}
  {% endif %}

  {% if grains.os_family == 'Suse' %}
    {% set npm_pkg_name = 'npm10' %}
    {% set update_nodejs = False %}
  {% elif grains.os == 'CentOS' %}
    {% if grains.osmajorrelease <= 7 %}
      {% set update_npm = False %}
    {% else %}
      {% set install_bin_path = '/usr/local/bin/' %}
    {% endif %}
  {% elif grains.os == 'Fedora' %}
    {% set install_bin_path = '/usr/local/bin/' %}
  {% elif grains.os == 'Ubuntu' %}
    {% set install_bin_path = '/usr/local/bin/' %}
    {% if grains.osmajorrelease <= 16 %}
      {% set nodejs_install = True %}
      {% set nodejs_pkg_name = 'nodejs-legacy' %}
    {% endif %}
  {% endif %}

{# Arcane path name setup due to some updates creating second copy of apps #}
{# Due to shell command hash not being updated $(npm bin -g)/command may fail #}
  {% if update_npm %}
    {% set npm_path_name = install_bin_path + npm_bin_name %}
  {% else %}
    {% set npm_path_name = package_bin_path + npm_bin_name %}
  {% endif %}
  {% if update_nodejs %}
    {% set node_path_name = install_bin_path + node_bin_name %}
  {% else %}
    {% set node_path_name = package_bin_path + node_bin_name %}
  {% endif %}

{# Most package managers include node/nodejs with npm installation #}
  {% if nodejs_install %}
nodejs-installed:
  pkg.installed:
    - name:     {{ nodejs_pkg_name }}
    {% if grains.cfg_nodejs.nodejs.version is defined %}
    - version:  {{ grains.cfg_nodejs.nodejs.version }}
    {% endif %}
  {% endif %}
npm-installed:
  pkg.installed:
    - name:     {{ npm_pkg_name }}
    {% if grains.cfg_nodejs.npm.version is defined %}
    - version:  {{ grains.cfg_nodejs.npm.version }}
    {% endif %}

{# Order required here as updated npm may require updated nodejs #}
  {% if update_nodejs %}
nodejs-latest:
  cmd.run:
    - onlyif:   command -v {{ nodejs_bin_name }}
    - name:     |
                {{ npm_bin_name }} cache clean -f
                {{ npm_bin_name }} install -g n
                {{ install_bin_path }}n stable
  {% endif %}
  {% if update_npm %}
npm-latest:
  cmd.run:
    - onlyif:   command -v {{ npm_bin_name }}
    - name:     {{ npm_bin_name }} install {{ npm_bin_name }}@latest -g
  {% endif %}

  {% if grains.cfg_nodejs.debug.enable %}
node-version:
  cmd.run:
    - name:     {{ node_path_name }} --version
npm-version:
  cmd.run:
    - name:     {{ npm_path_name }} --version
  {% endif %}
{% endif %}
