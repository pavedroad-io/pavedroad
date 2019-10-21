# Install kubebuilder

{% set installs = grains.cfg_kubebuilder.installs %}
{% set completion = grains.cfg_kubebuilder.completion %}

{% if installs and 'kubebuilder' in installs %}
  {% set kubebuilder_pkg_name = 'kubebuilder' %}
  {% set kubebuilder_binary_install = True %}
  {% set kubebuilder_path = '/usr/local/bin/' %}
  {% set kubebuilder_tmp_dir = '/tmp' %}
  {% set kubebuilder_testdir = grains.gopath + '/src/testkubebuilder' %}

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

  {% if completion and 'bash' in completion %}
include:
  - bash
  {% endif %}

kubebuilder:
  {# tar file contains 4 binaries in /bin, only copy kubebuilder #}
  {% if kubebuilder_binary_install %}
  archive.extracted:
    - unless:         command -v {{ kubebuilder_pkg_name }}
    - name:           {{ kubebuilder_tmp_dir }}
    - source:         {{ kubebuilder_url }}
    - tar_options:    z
    - archive_format: tar
    - skip_verify:    True
  file.managed:
    - unless:    command -v {{ kubebuilder_pkg_name }}
    - name:      {{ kubebuilder_path }}{{ kubebuilder_pkg_name}}
    - source:    {{ kubebuilder_tmp_path }}{{ kubebuilder_pkg_name }}
    - mode:      755
  {% else %}
  pkg.installed:
    - unless:   command -v {{ kubebuilder_pkg_name }}
    - name:     {{ kubebuilder_pkg_name }}
    {% if grains.cfg_kubebuilder.kubebuilder.version is defined %}
    - version:  {{ grains.cfg_kubebuilder.kubebuilder.version }}
    {% endif %}
  {% endif %}

  {% if completion and 'bash' in completion %}
    {% if grains.os_family == 'MacOS' %}
      {% set bash_comp_dir = '/usr/local/etc/bash_completion.d/' %}
    {% else %}
      {% set bash_comp_dir = '/usr/share/bash-completion/completions/' %}
    {% endif %}
    {% set bash_comp_file = bash_comp_dir + 'kubebuilder' %}
kubebuilder-bash-completion:
  cmd.run:
    - name:     {{ kubebuilder_path }}{{ kubebuilder_pkg_name }} completion bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ kubebuilder_path }}{{ kubebuilder_pkg_name }}
    - require:
      - sls:    bash
  {% endif %}

  {% if grains.cfg_kubebuilder.debug.enable %}
  {# kubebuilder must be run from some $GOPATH/src/<package> directory #}
kubebuilder-version:
  cmd.run:
    - name:     |
                mkdir -p {{ kubebuilder_testdir }}
                cd {{ kubebuilder_testdir }}
                {{ kubebuilder_path }}{{ kubebuilder_pkg_name }} version
                rm -rf {{ kubebuilder_testdir }}
  {% endif %}
{% endif %}
