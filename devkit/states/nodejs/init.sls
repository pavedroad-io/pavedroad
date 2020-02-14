# Install nodejs (node and npm)

# npm completion: see https://docs.npmjs.com/cli-commands/completion.html
# Cannot get either bash or zsh completion to work using this
# brew installs the bash completion file on MacOS that npm generates

{% set installs = grains.cfg_nodejs.installs %}

{% if installs and 'nodejs' in installs %}
  {% set npm_pkg_name = 'npm' %}
  {% set node_bin_name = 'node' %}
  {% set npm_bin_name = 'npm' %}
  {% if grains.os_family == 'Suse' %}
    {% set npm_pkg_name = 'npm10' %}
  {% endif %}

{# All package managers install node/nodejs with npm #}
npm-installed:
  pkg.installed:
    - name:     {{ npm_pkg_name }}
  {% if grains.cfg_nodejs.nodejs.version is defined %}
    - version:  {{ grains.cfg_nodejs.nodejs.version }}
  {% endif %}

  {% if grains.os_family in ('Debian', 'Suse') %}
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
