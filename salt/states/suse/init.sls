# Install suse packages

{% set installs = grains.cfg_suse.installs %}

{% if installs and 'devtools' in installs %}
devtools:
  cmd.run:
    - name:     "zypper install -y -t pattern devel_basis"
{% endif %}
