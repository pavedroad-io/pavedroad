# Install git

{% set installs = grains.cfg_git.installs %}

{% if installs and 'git' in installs %}
git:
  pkg.installed:
    - name:     git
  {% if grains.cfg_git.git.version is defined %}
    - version:  {{ grains.cfg_git.git.version }}
  {% endif %}
{% endif %}
