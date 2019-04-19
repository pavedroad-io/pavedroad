# Install redhat packages

{% set installs = grains.cfg_redhat.installs %}

{% if installs and 'devtools' in installs %}
devtools:
  cmd.run:
    - name:     "yum -q -y groupinstall 'Development Tools'"
{% endif %}
