# Install jq

{% set installs = grains.cfg_jq.installs %}
{% set completion = grains.cfg_jq.completion %}
{% set jq_pkg_name = 'jq' %}

{% if installs and 'jq' in installs %}

jq:
  pkg.installed:
  {% if grains.os_family == 'MacOS' %}
    - unless:   brew list {{ jq_pkg_name }}
  {% else %}
    - unless:   command -v {{ jq_pkg_name }}
  {% endif %}
    - name:     {{ jq_pkg_name }}
  {% if grains.cfg_jq.jq.version is defined %}
    - version:  {{ grains.cfg_jq.jq.version }}
  {% endif %}
  {% if completion %}
    {# Cannot find bash completion #}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_jq' %}
jq-zsh-completion:
  file.managed:
    - name:     {{ zsh_comp_file }}
    - source:   https://github.com/zsh-users/zsh/blob/master/Completion/Unix/Command/_jq
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
  {% endif %}

  {% if grains.cfg_jq.debug.enable %}
jq-version:
  cmd.run:
    - name:     {{ jq_pkg_name }} --version
  {% endif %}
{% endif %}

