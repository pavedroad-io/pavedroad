# Install windows packages

{% set installs = grains.cfg_windows.installs %}

# Unclear if salt windows bootstrap installs choco
# Or if win_pkg is able to use choco to do installs
chocolatey:
  pkg.installed

{% if installs and 'devtools' in installs %}
devtools:
  chocolatey.installed:
    - name:     windows-sdk
    - version:  {{ grains.cfg_windows.devtools.version }}
    - require:
      - pkg: chocolatey
{% endif %}

{% if installs and 'cygwin' in installs %}
cygwin:
  chocolatey.installed:
    - name:     cygwin
    - version:  {{ grains.cfg_windows.cygwin.version }}
    - require:
      - pkg: chocolatey
{% endif %}

{% if installs and 'putty' in installs %}
putty:
  chocolatey.installed:
    - name:     putty
    - version:  {{ grains.cfg_windows.putty.version }}
    - require:
      - pkg: chocolatey
{% endif %}
