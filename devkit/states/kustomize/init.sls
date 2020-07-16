# Install kustomize

{% set installs = grains.cfg_kustomize.installs %}

{% if installs and 'kustomize' in installs %}
  {% set kustomize_bin_name = 'kustomize' %}
  {% set kustomize_pkg_name = 'kustomize' %}
  {% set kustomize_binary_install = True %}
  {% set kustomize_path = '/usr/local/bin' %}

  {% if grains.cfg_kustomize.kustomize.version is defined and
    grains.cfg_kustomize.kustomize.version != 'latest' %}
    {% set kustomize_version = grains.cfg_kustomize.kustomize.version %}
  {% else %}
    {% set kustomize_version = 'latest' %}
  {% endif %}

  {% if kustomize_binary_install %}
    {% if kustomize_version == 'latest' %}
      {% set kustomize_url = 'https://raw.githubusercontent.com/kubernetes-sigs' %}
      {% set kustomize_url = kustomize_url + '/kustomize/master/hack/' %}
      {% set kustomize_url = kustomize_url + 'install_kustomize.sh' %}
    {% else %}
      {% set kustomize_url = 'https://github.com/kubernetes-sigs/kustomize' %}
      {% set kustomize_url = kustomize_url + '/releases/download/kustomize' %}
      {% set kustomize_url = kustomize_url + '/v' + kustomize_version %}
      {% set kustomize_url = kustomize_url + '/kustomize_v' + kustomize_version %}
      {% if grains.os_family == 'MacOS' %}
        {% set kustomize_url = kustomize_url + '_darwin_amd64' %}
      {% else %}
        {% set kustomize_url = kustomize_url + '_linux_amd64' %}
      {% endif %}
      {% set kustomize_url = kustomize_url + '.tar.gz' %}
    {% endif %}
  {% endif %}

  {% if kustomize_binary_install %}
    {% if kustomize_version == 'latest' %}
kustomize-script:
  cmd.script:
    - unless:   command -v {{ kustomize_bin_name }}
    - source:   {{ kustomize_url }}
    - cwd:      {{ kustomize_path }}
    {% else %}
kustomize-binary:
  {# Archive does not have a top-level directory - negate enforce_toplevel #}
  {# tar file only contains the kustomize binary #}
  archive.extracted:
    - unless:           comman -v {{ kustomize_bin_name }}
    - name:             {{ kustomize_path }}
    - source:           {{ kustomize_url }}
    - archive_format:   tar
    - options:          v
    - skip_verify:      True
    - enforce_toplevel: False
    {% endif %}
  {% else %}
  pkg.installed:
    - unless:   command -v {{ kustomize_bin_name }}
    - name:     {{ kustomize_bin_name }}
    - version:  {{ kustomize_version }}
  {% endif %}

  {% if grains.cfg_kustomize.debug.enable %}
kustomize-version:
  cmd.run:
    - name:     {{ kustomize_path }}/{{ kustomize_bin_name }} version
  {% endif %}
{% endif %}
