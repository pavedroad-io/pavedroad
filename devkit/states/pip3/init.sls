# Install pip3
#
# Old salt versions need pip2 for pip.installed to work with pip3 like this:
# command:
#   pip.installed:
#     - bin_env: /usr/bin/pip3
# However, pip2 is not installed on systems that no longer support python2
#
# MacOS installs pip3 as part of python3
# Using salt versioning python=3 does not work with brew

{% set installs = grains.cfg_pip3.installs %}
{% set pip2_install = False %}
{# Following no longer needed after January 1, 2020 #}
{# {% if (grains.os == 'Ubuntu' and grains.osmajorrelease <= 19)
  or (grains.os == 'CentOS' and grains.osmajorrelease <= 7)
  or (grains.os == 'Fedora' and grains.osmajorrelease <= 31) %}
  {% set pip2_install = True %}
{% endif %} #}

{% if installs and 'pip3' in installs %}
pip3:
  pkg.installed:
    - unless:   command -v pip3
  {% if grains.os_family == 'MacOS' %}
    - name:     python@3
  {% else %}
    - pkgs:
      - python3-pip
    {% if pip2_install %}
      {% if grains.os_family == 'Debian' %}
      - python-pip
      {% else %}
      - python2-pip
      {% endif %}
    {% endif %}
  {% endif %}

  {% if grains.cfg_pip3.debug.enable %}
pip3-version:
  cmd.run:
    - name:     pip3 --version
  {% endif %}
{% endif %}
