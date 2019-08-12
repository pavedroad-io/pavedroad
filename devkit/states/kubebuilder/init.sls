# Install kubebuilder

{% set installs = grains.cfg_kubebuilder.installs %}
{% set completion = grains.cfg_kubebuilder.completion %}

{% if installs and 'kubebuilder' in installs %}
  {% set kubebuilder_pkg_name = 'kubebuilder' %}
  {% set kubebuilder_directory_install = True %}
  {% if grains.os_family == 'MacOS' %}
    {% set kubebuilder_directory = '/usr/local/opt' %}
  {% else %}
    {% set kubebuilder_directory = '/usr/local' %}
  {% endif %}
  {% set kubebuilder_path = kubebuilder_directory + '/' + kubebuilder_pkg_name + '/bin/' %}
  {% set kubebuilder_testdir = grains.gopath + '/src/testkubebuilder' %}

  {% if kubebuilder_directory_install %}
    {% if grains.cfg_kubebuilder.kubebuilder.version is defined %}
      {% set version = grains.cfg_kubebuilder.kubebuilder.version %}
    {% else %}
      {% set version = 'latest' %}
    {% endif %}
    {% set kubebuilder_prefix = 'https://go.kubebuilder.io/dl/' %}
    {% if grains.os_family == 'MacOS' %}
      {% set kubebuilder_version = version + '/darwin/amd64' %}
      {% set kubebuilder_file = 'kubebuilder_' + version + '_darwin_amd64' %}
    {% else %}
      {% set kubebuilder_version = version + '/linux/amd64' %}
      {% set kubebuilder_file = 'kubebuilder_' + version + '_linux_amd64' %}
    {% endif %}
    {% set kubebuilder_url = kubebuilder_prefix + kubebuilder_version %}
  {% endif %}

  {# Need bash installed so kubebuilder path can be added to .bashrc #}
include:
  - bash

kubebuilder:
  {% if kubebuilder_directory_install %}
    archive.extracted:
      - unless:         command -v {{ kubebuilder_pkg_name }}
      - name:           {{ kubebuilder_directory }}
      - source:         {{ kubebuilder_url }}
      - tar_options:    z
      - archive_format: tar
      - skip_verify:    True
    cmd.run:
      - unless:   test -x {{ kubebuilder_directory }}/{{ kubebuilder_pkg_name}} 
      - name:     cd {{ kubebuilder_directory }}; mv {{ kubebuilder_file}} {{ kubebuilder_pkg_name}} 
    file.append:
      - name:     {{ grains.homedir }}/.bashrc
      - text:     export PATH=$PATH:{{ kubebuilder_path }}
      - require:
        - sls:    bash
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
