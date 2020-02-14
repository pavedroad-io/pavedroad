# Install fzf

{% set installs = grains.cfg_fzf.installs %}
{% set completion = grains.cfg_fzf.completion %}

{% if installs and 'fzf' in installs %}
  {% set fzf_plugin = grains.homedir + '/.vim/plugged/fzf' %}
{# fzf is installed using vim-plug in vim/init.sls #}
{# The binary, completion files and the man page are copied as needed #}
fzf-binary:
  file.managed:
    - name:        /usr/local/bin/fzf
    - source:      {{ fzf_plugin }}/bin/fzf
    - makedirs:    True
    - skip_verify: True
    - replace:     True
    - mode:        755
fzf-man-page:
  file.managed:
    - name:        /usr/local/share/man/man1/fzf.1
    - source:      {{ fzf_plugin }}/man/man1/fzf.1
    - makedirs:    True
    - skip_verify: True
    - replace:     True
  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/fzf' %}
fzf-bash-completion:
  file.managed:
    - name:        {{ bash_comp_file }}
    - source:      {{ fzf_plugin }}/shell/completion.bash
    - makedirs:    True
    - skip_verify: True
    - replace:     True
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_fzf' %}
fzf-zsh-completion:
  file.managed:
    - name:        {{ zsh_comp_file }}
    - source:      {{ fzf_plugin }}/shell/completion.zsh
    - makedirs:    True
    - skip_verify: True
    - replace:     True
    {% endif %}
  {% endif %}
fzf-append-pr_bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     source $HOME/.vim/plugged/fzf/shell/key-bindings.bash 2> /dev/null
fzf-append-pr_zshrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     source $HOME/.vim/plugged/fzf/shell/key-bindings.zsh 2> /dev/null
{% endif %}

