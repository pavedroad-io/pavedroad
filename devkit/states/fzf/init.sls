# Install fzf

{% set installs = grains.cfg_fzf.installs %}
{% set completion = grains.cfg_fzf.completion %}

{% if installs and 'fzf' in installs %}
{# fzf is installed using "go get" in golang/init.sls #}
{# Only completion files are installed here #}
  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/fzf' %}
fzf-bash-completion:
  file.managed:
    - name:     {{ bash_comp_file }}
    - source:   https://github.com/junegunn/fzf/blob/master/shell/completion.bash
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_fzf' %}
fzf-zsh-completion:
  file.managed:
    - name:     {{ zsh_comp_file }}
    - source:   https://github.com/junegunn/fzf/blob/master/shell/completion.zsh
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
  {% endif %}
{% endif %}

