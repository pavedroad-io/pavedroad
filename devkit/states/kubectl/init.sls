# Install kubectl

{% set installs = grains.cfg_kubectl.installs %}
{% set completion = grains.cfg_kubectl.completion %}

{% if installs and 'kubectl' in installs %}
  {% set kubectl_pkg_name = 'kubectl' %}
  {% set kubectl_binary_install = True %}
  {% set kubectl_snap_install = False %}
  {% set kubectl_path = '/usr/local/bin/' %}

  {% if kubectl_binary_install %}
    {% set kubectl_prefix = 'https://storage.googleapis.com/kubernetes-release/release/' %}
    {% set version = salt.cmd.run('curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt') %}
    {% if grains.os_family == 'MacOS' %}
      {% set kubectl_version = version + '/bin/darwin/amd64/kubectl' %}
    {% else %}
      {% set kubectl_version = version + '/bin/linux/amd64/kubectl' %}
    {% endif %}
    {% set kubectl_url = kubectl_prefix + kubectl_version %}
  {% elif kubectl_snap_install %}
    {% set kubectl_path = '/snap/bin/' %}
  {% endif %}

  {% if kubectl_snap_install %}
include:
  - snapd
  {% endif %}

kubectl:
  {% if kubectl_binary_install %}
  file.managed:
    - name:     {{ kubectl_path }}kubectl
    - source:   {{ kubectl_url }}
    - makedirs: True
    - skip_verify: True
    - mode:     755
    - replace:  False
  {% elif kubectl_snap_install %}
  cmd.run:
    - require:
      - sls:    snapd
    - unless:   snap list | grep kubectl
    - name:     snap install kubectl
  {% else %}
  pkg.installed:
    - unless:   command -v kubectl
    - name:     kubectl
    {% if grains.cfg_kubectl.kubectl.version is defined %}
    - version:  {{ grains.cfg_kubectl.kubectl.version }}
    {% endif %}
  {% endif %}

# brew install kubectl also installs bash completion for kubectl
# so we do not overwrite completion file

  {% if completion %}
    {% if 'bash' in completion %}
      {% set bash_comp_file = pillar.directories.completions.bash + '/kubectl' %}
kubectl-bash-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.bash }}
                {{ kubectl_path }}kubectl completion bash > {{ bash_comp_file }}
    - unless:   test -e {{ bash_comp_file }}
    - onlyif:   test -x {{ kubectl_path }}kubectl
    {% endif %}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '_kubectl' %}
kubectl-zsh-completion:
  cmd.run:
    - name:     |
                mkdir -p {{ pillar.directories.completions.zsh }}
                {{ kubectl_path }}kubectl completion zsh > {{ zsh_comp_file }}
    - unless:   test -e {{ zsh_comp_file }}
    - onlyif:   test -x {{ kubectl_path }}kubectl
    {% endif %}
  {% endif %}

  {% if grains.cfg_kubectl.debug.enable %}
  {# kubectl version returns 1 if no server connection #}
kubectl-version:
  cmd.run:
    - name:     {{ kubectl_path }}kubectl version
    - success_retcodes: 1
  {% endif %}
{% endif %}
