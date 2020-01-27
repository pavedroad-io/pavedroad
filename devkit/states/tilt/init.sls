# Install tilt

{% set installs = grains.cfg_tilt.installs %}

{% if installs and 'tilt' in installs %}
  {% set tilt_pkg_name = 'tilt' %}
  {% set tilt_path = '/usr/local/bin' %}
  {% set tilt_temp= '/tmp/tilt' %}
  {% set tilt_script = 'install.sh' %}

tilt-script:
  file.managed:
    - unless:      command -v {{ tilt_pkg_name }}
    - name:        {{ tilt_temp }}/{{ tilt_script }}
    - source:      https://raw.githubusercontent.com/windmilleng/tilt/master/scripts/install.sh
    - makedirs:    True
    - skip_verify: True
    - replace:     False
  {# Docker: remove sudo from script if not installed #}
  {% if grains.docker %}
  cmd.run:
    - unless:   command -v sudo
    - name:     sed -i -e "s/sudo//" ./{{ tilt_script }}
    - cwd:      {{ tilt_temp }}
  {% endif %}
tilt-install:
  cmd.run:
    - unless:   command -v {{ tilt_pkg_name }}
    - name:     bash {{ tilt_script }}
    - cwd:      {{ tilt_temp }}
  {% if grains.cfg_tilt.debug.enable %}
tilt-version:
  cmd.run:
    - name:     {{ tilt_path }}/{{ tilt_pkg_name }} version
  {% endif %}
{% endif %}

