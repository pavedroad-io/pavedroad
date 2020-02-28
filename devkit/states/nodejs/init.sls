# Install nodejs (node and npm)

# npm completion: see https://docs.npmjs.com/cli-commands/completion.html
# Cannot get either bash or zsh completion to work using this
# brew installs the bash completion file on MacOS that npm generates

{% set installs = grains.cfg_nodejs.installs %}

{% if installs and 'nodejs' in installs %}
  {% set npm_pkg_name = 'npm' %}
  {% set node_bin_name = 'node' %}
  {% set npm_bin_name = 'npm' %}
  {% set update_npm = True %}

  {% set nodejs_install = False %}
  {% set nodejs_pkg_name = 'nodejs' %}
  {% set nodejs_bin_name = 'node' %}
  {% set update_nodejs = True %}

  {% if grains.os_family == 'Suse' %}
    {% set npm_pkg_name = 'npm10' %}
    {% set update_nodejs = False %}
  {% elif grains.os == 'CentOS' %}
    {% set update_npm = False %}
  {% elif grains.os == 'Ubuntu' and grains.osmajorrelease < 18 %}
    {% set nodejs_install = True %}
    {% set nodejs_pkg_name = 'nodejs-legacy' %}
  {% endif %}

{# Most package managers install node/nodejs with npm #}
  {% if nodejs_install %}
nodejs-installed:
  pkg.installed:
    - name:     {{ nodejs_pkg_name }}
  {% endif %}
npm-installed:
  pkg.installed:
    - name:     {{ npm_pkg_name }}
  {% if grains.cfg_nodejs.nodejs.version is defined %}
    - version:  {{ grains.cfg_nodejs.nodejs.version }}
  {% endif %}

  {% if update_nodejs %}
nodejs-latest:
  cmd.run:
    - onlyif:   command -v {{ nodejs_bin_name }}
    - name:     |
                npm install n -g
                n stable
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
    - name:     {{ node_bin_name }} --version
npm-version:
  cmd.run:
    - name:     {{ npm_bin_name }} --version
  {% endif %}
{% endif %}
