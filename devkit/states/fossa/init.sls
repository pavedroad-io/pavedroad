# Install fossa

{% set installs = grains.cfg_fossa.installs %}

{% if installs and 'fossa' in installs %}
  {% set fossa_pkg_name = 'fossa' %}
  {% set fossa_path = '/usr/local/bin' %}
  {% set fossa_temp= '/tmp/fossa' %}
  {% set fossa_script = 'install.sh' %}
  {% if grains.cfg_fossa.fossa.version is defined %}
    {% set fossa_pkg_version = grains.cfg_fossa.fossa.version %}
  {% else %}
    {% set fossa_pkg_version = '' %}
  {% endif %}

fossa-script:
  file.managed:
    - unless:      command -v {{ fossa_pkg_name }}
    - name:        {{ fossa_temp }}/{{ fossa_script }}
    - source:      https://raw.githubusercontent.com/fossas/fossa-cli/master/install.sh
    - makedirs:    True
    - skip_verify: True
    - replace:     False
fossa-temp-dir:
  {# Workaround for salt bug: cmd.run checks for cwd before unless/onlyif #}
  file.directory:
    - name:     {{ fossa_temp }}
    - makedirs: True
fossa-install:
  cmd.run:
    - unless:   command -v {{ fossa_pkg_name }}
    - name:     sh {{ fossa_script }} {{ fossa_pkg_version}}
    - cwd:      {{ fossa_temp }}
  {% if grains.cfg_fossa.debug.enable %}
fossa-version:
  cmd.run:
    - name:     {{ fossa_path }}/{{ fossa_pkg_name }} --version
  {% endif %}
{% endif %}

