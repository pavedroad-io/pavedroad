# Install tilt

{% set installs = grains.cfg_tilt.installs %}

{% if installs and 'tilt' in installs %}
  {% set tilt_bin_name = 'tilt' %}
  {% set tilt_path = '/usr/local/bin' %}
  {% set tilt_temp= '/tmp/tilt' %}
  {% set tilt_script = 'install.sh' %}

tilt-temp-dir:
  {# Workaround for salt bug: cmd.run checks for cwd before unless/onlyif #}
  file.directory:
    - name:     {{ tilt_temp }}
    - makedirs: True
tilt-script:
  file.managed:
    - unless:      command -v {{ tilt_bin_name }}
    - name:        {{ tilt_temp }}/{{ tilt_script }}
    - source:      https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh
    - makedirs:    True
    - skip_verify: True
    - replace:     False
  {# Docker: remove sudo from script if not installed #}
  {% if grains.docker %}
docker-fix:
  cmd.run:
    - unless:   command -v {{ tilt_bin_name }}
    - onlyif:   (! command -v sudo)
    - name:     sed -i -e "s/sudo//" ./{{ tilt_script }}
    - cwd:      {{ tilt_temp }}
  {% endif %}
tilt-install:
  {# Install script fails unless PATH is set correctly #}
  cmd.run:
    - unless:   command -v {{ tilt_bin_name }}
    - name:     PATH={{ tilt_path }}:$PATH bash {{ tilt_script }}
    - cwd:      {{ tilt_temp }}
    - require:
      - file:   tilt-script
  {% if grains.cfg_tilt.debug.enable %}
tilt-version:
  cmd.run:
    - name:     {{ tilt_path }}/{{ tilt_bin_name }} version
  {% endif %}
{% endif %}

