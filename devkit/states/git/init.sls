# Install git

{% set installs = grains.cfg_git.installs %}
{% set completion = grains.cfg_git.completion %}

{% if installs and 'git' in installs %}
  {% set git_pkg_name = 'git' %}
{# Should not be needed as bootstrap installs git #}
git:
  pkg.installed:
    - unless:   command -v {{ git_pkg_name }}
    - name:     {{ git_pkg_name }}
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
git-append-pr_bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     source $HOME/.pr_git_aliases
    - require:
      - file:   pr-git-aliases
git-append-pr_zshrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     source $HOME/.pr_git_aliases
    - require:
      - file:   pr-git-aliases
{% endif %}

{# bash and zsh completions installed by bash-completion, git and/or zsh packages #}

{% if installs and 'prompt' in installs %}
  {% set git_prefix = 'https://raw.githubusercontent.com/git' %}
  {% set git_content = '/git/master/contrib/completion' %}
  {% set git_prompt_url = git_prefix + git_content + '/git-prompt.sh' %}

git-prompt:
  file.managed:
    - name:     {{ grains.homedir }}/.git-prompt.sh
    - source:   {{ git_prompt_url }}
    - skip_verify: True
    - replace:  False
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
pr_bash_prompt:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_bash_prompt
    - source:   salt://git/pr_bash_prompt
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if grains.cfg_git.prompt.append %}
pr_bashrc-git:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     source $HOME/.pr_bash_prompt
    - require:
      - file:   git-prompt
      - file:   pr_bash_prompt
  {% endif %}
pr_zsh_prompt:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_zsh_prompt
    - source:   salt://git/pr_zsh_prompt
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if grains.cfg_git.prompt.append %}
pr_zshrc-git:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     source $HOME/.pr_zsh_prompt
    - require:
      - file:   git-prompt
      - file:   pr_zsh_prompt
  {% endif %}

  {% if grains.cfg_git.debug.enable %}
git-version:
  cmd.run:
    - name:     {{ git_pkg_name }} --version
  {% endif %}
{% endif %}
