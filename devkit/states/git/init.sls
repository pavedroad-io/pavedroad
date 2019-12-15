# Install git

{% set installs = grains.cfg_git.installs %}
{% set completion = grains.cfg_git.completion %}

{% if completion and 'bash' in completion %}
include:
  - bash
{% endif %}

{% if installs and 'git' in installs %}
{# Should not be needed as bootstrap installs git #}
git:
  pkg.installed:
    - unless:   command -v git
    - name:     git
  {% if grains.cfg_git.git.version is defined %}
    - version:  {{ grains.cfg_git.git.version }}
  {% endif %}
pr-git-aliases:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_git_aliases
    - source:   salt://git/pr_git_aliases
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
append-pr_bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     source $HOME/.pr_git_aliases
    - require:
      - file:   pr-git-aliases
append-pr_zshrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     source $HOME/.pr_git_aliases
    - require:
      - file:   pr-git-aliases
{% endif %}

# MacOS - brew install git also installs git-completion.bash and git-prompt.sh
# CentOS - has its own specific version of git completion for bash

{% set git_prefix = 'https://raw.githubusercontent.com/git' %}
{% set git_content = '/git/master/contrib/completion' %}

{% if completion and 'bash' in completion %}
  {% if not grains.os_family == 'MacOS' and not grains.os == 'CentOS' %}
    {% set git_comp_url = git_prefix + git_content + '/git-completion.bash' %}
    {% set bash_comp_dir = '/usr/share/bash-completion/completions' %}

git-bash-completion:
  file.managed:
    - name:     {{ bash_comp_dir }}/git
    - source:   {{ git_comp_url }}
    - makedirs: True
    - skip_verify: True
    - replace:  False
    - require:
      - sls:    bash
  {% endif %}
{% endif %}

{% if installs and 'prompt' in installs %}
  {% set git_prompt_url = git_prefix + git_content + '/git-prompt.sh' %}

git-bash-prompt:
  file.managed:
    - name:     {{ grains.homedir }}/.git-prompt.sh
    - source:   {{ git_prompt_url }}
    - skip_verify: True
    - replace:  False
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
    - require:
      - sls:    bash
pr-bash-prompt:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bash_prompt
    - source:   salt://git/pr_bash_prompt
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if grains.cfg_git.prompt.append %}
append-source-prompt:
  file.append:
    - name:     {{ grains.homedir }}/.bashrc
    - text:     source $HOME/.pr_bash_prompt
    - require:
      - file:   git-bash-prompt
      - file:   pr-bash-prompt
  {% endif %}
{% endif %}
