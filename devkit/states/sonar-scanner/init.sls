# Install sonar-scanner

{% set installs = grains.cfg_sonar_scanner.installs %}

{% if installs and 'sonar_scanner' in installs %}
  {% set sonar_scanner_pkg_name = 'sonar-scanner' %}
  {% set sonar_scanner_path = '/usr/local/bin/' %}
  {% set sonar_scanner_tmp_dir = '/tmp/sonar-scanner/' %}
  {% set sonar_scanner_binary_install = True %}
  {% if grains.os_family == 'MacOS' %}
    {% set sonar_scanner_lib_dir = '/usr/local/lib/' %}
  {% else %}
    {% set sonar_scanner_lib_dir = '/usr/lib/' %}
  {% endif %}

  {% if sonar_scanner_binary_install %}
    {% set sonar_scanner_prefix =
      'https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-' %}
    {% if grains.cfg_sonar_scanner.sonar_scanner.version is defined and
      grains.cfg_sonar_scanner.sonar_scanner.version != 'latest' %}
      {% set version = grains.cfg_sonar_scanner.sonar_scanner.version %}
      {% if grains.os_family == 'MacOS' %}
        {% set sonar_scanner_version = version + '-macosx' %}
      {% else %}
        {% set sonar_scanner_version = version + '-linux' %}
      {% endif %}
      {% set sonar_scanner_zip_file = sonar_scanner_version + '.zip' %}
      {% set sonar_scanner_url = sonar_scanner_prefix + sonar_scanner_zip_file %}
      {% set sonar_scanner_file = sonar_scanner_pkg_name + '-' + sonar_scanner_version %}
    {% else %}
      {% set sonar_scanner_properties =
        'https://raw.githubusercontent.com/SonarSource/sonar-update-center-properties/master/scannercli.properties' %}
      {% set sonar_scanner_version = salt.cmd.shell('curl -s ' + sonar_scanner_properties
        + ' | grep publicVersions | sed -e s/publicVersions=//') %}
      {% if grains.os_family == 'MacOS' %}
        {% set sonar_scanner_grep = sonar_scanner_version + '.downloadUrl.macos' %}
      {% else %}
        {% set sonar_scanner_grep = sonar_scanner_version + '.downloadUrl.linux' %}
      {% endif %}
      {% set sonar_scanner_url = salt.cmd.shell('curl -s ' + sonar_scanner_properties
        + ' | grep ' + sonar_scanner_grep + ' | sed s/' + sonar_scanner_grep + '=//') %}
      {% set sonar_scanner_file = salt.cmd.shell('echo ' + sonar_scanner_url
        + ' | sed -e "s|^.*-cli/||" -e "s/-cli//" -e "s/.zip//"') %}
    {% endif %}
    {% set sonar_scanner_lib_path = sonar_scanner_lib_dir + sonar_scanner_pkg_name + '/bin/' %}
  {% endif %}

sonar_scanner:
  {% if sonar_scanner_binary_install %}
  archive.extracted:
    - unless:         command -v {{ sonar_scanner_pkg_name }}
    - name:           {{ sonar_scanner_tmp_dir }}
    - source:         {{ sonar_scanner_url }}
    - skip_verify:    True
    - archive_format: zip
  file.copy:
    - unless:   command -v {{ sonar_scanner_pkg_name }}
    - name:     {{ sonar_scanner_lib_dir }}{{ sonar_scanner_pkg_name }}
    - source:   {{ sonar_scanner_tmp_dir }}{{ sonar_scanner_file }}
sonar_scanner_link:
  file.symlink:
    - unless:   command -v {{ sonar_scanner_pkg_name }}
    - name:     {{ sonar_scanner_path }}{{ sonar_scanner_pkg_name }}
    - target:   {{ sonar_scanner_lib_path }}{{ sonar_scanner_pkg_name }}
  {% else %}
  pkg.installed:
    - unless:   command -v {{ sonar_scanner_pkg_name }}
    - name:     {{ sonar_scanner_pkg_name }}
    {% if grains.cfg_sonar_scanner.sonar_scanner.version is defined %}
    - version:  {{ grains.cfg_sonar_scanner.sonar_scanner.version }}
    {% endif %}
  {% endif %}

  {% if grains.cfg_sonar_scanner.debug.enable %}
sonar_scanner-version:
  cmd.run:
    - name:     {{ sonar_scanner_path }}{{ sonar_scanner_pkg_name }} -v
  {% endif %}
{% endif %}
