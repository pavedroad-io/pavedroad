# Install kubebuilder

{% set installs = grains.cfg_kubebuilder.installs %}

{% if installs and 'kubebuilder' in installs %}
  {% set kubebuilder_pkg_name = 'kubebuilder' %}
  {% set kubebuilder_path = '/usr/local/bin/' + kubebuilder_pkg_name %}
  {% set kubebuilder_binary_install = True %}
  {% set kubebuilder_tmp_dir = '/tmp' %}
  {% set kubebuilder_testdir = grains.homedir + '/go/src/testkubebuilder' %}

  {# kubebuilder download url only supports latest and not version numbers #}
  {% if kubebuilder_binary_install %}
    {% if grains.cfg_kubebuilder.kubebuilder.version is defined %}
      {% set version = grains.cfg_kubebuilder.kubebuilder.version %}
    {% else %}
      {% set version = 'latest' %}
    {% endif %}
    {% set kubebuilder_prefix = 'https://go.kubebuilder.io/dl/' %}
    {% if grains.os_family == 'MacOS' %}
      {% set kubebuilder_version = version + '/darwin/amd64' %}
      {% set kubebuilder_tar_file = 'kubebuilder_' + version + '_darwin_amd64' %}
    {% else %}
      {% set kubebuilder_version = version + '/linux/amd64' %}
      {% set kubebuilder_tar_file = 'kubebuilder_' + version + '_linux_amd64' %}
    {% endif %}
    {% set kubebuilder_tmp_path = kubebuilder_tmp_dir + '/' + kubebuilder_tar_file + '/bin/' %}
    {% set kubebuilder_url = kubebuilder_prefix + kubebuilder_version %}
  {% endif %}

kubebuilder:
  {# kubebuilder binary is no longer contained in a tar file #}
  {% if kubebuilder_binary_install %}
  file.managed:
    - name:        {{ kubebuilder_path }}
    - source:      {{ kubebuilder_url }}
    - skip_verify: True
    - mode:        755
  {% else %}
  pkg.installed:
    - unless:   command -v {{ kubebuilder_pkg_name }}
    - name:     {{ kubebuilder_pkg_name }}
    {% if grains.cfg_kubebuilder.kubebuilder.version is defined %}
    - version:  {{ grains.cfg_kubebuilder.kubebuilder.version }}
    {% endif %}
  {% endif %}

  {% if grains.cfg_kubebuilder.debug.enable %}
  {# kubebuilder must be run from some $GOPATH/src/<package> directory #}
kubebuilder-version:
  cmd.run:
    - name:     |
                mkdir -p {{ kubebuilder_testdir }}
                cd {{ kubebuilder_testdir }}
                {{ kubebuilder_path }} version
                rm -rf {{ kubebuilder_testdir }}
  {% endif %}
{% endif %}
