# Install pip3
#
# Need pip2 for salt pip.installed to work with pip3 like this:
# somthing:
#   pip.installed:
#     - bin_env: /usr/bin/pip3
#
# MacOS installs pip3 as part of python3
# salt versioning python=3 does not work with brew

{% set installs = grains.cfg_pip3.installs %}

{% if installs and 'pip3' in installs %}
pip3:
  pkg.installed:
    - unless:   command -v pip3
  {% if grains.os_family == 'MacOS' %}
    - name:     python@3
  {% else %}
    - pkgs:
    {% if grains.os_family == 'Debian' %}
      - python-pip
      - python3-pip
    {% elif grains.os_family == 'RedHat' %}
      - python2-pip
      - python34-pip
    {% else %}
      - python2-pip
      - python3-pip
    {% endif %}
  cmd.run:
    - onlyif:   test -x /usr/bin/pip3.4
    - unless:   test -x /usr/bin/pip3
    - name:     ln -s /usr/bin/pip3.4 /usr/bin/pip3
  {% endif %}
{% endif %}
