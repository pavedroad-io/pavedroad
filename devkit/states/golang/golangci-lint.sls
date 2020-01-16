# Install golangci-lint
# Quote from: https://github.com/golangci/golangci-lint
# Please, do not install golangci-lint by go get

{% set installs = grains.cfg_golang.installs %}

{% if installs and 'golangci-lint' in installs %}
  {% set golangci_lint_pkg_name = 'golangci-lint' %}
  {% set golangci_lint_path = grains.homedir + '/go/bin' %}
  {% set golangci_lint_temp= '/tmp/golangci-lint' %}
  {% set golangci_lint_script = 'install.sh' %}

golangci-lint-path:
  file.directory:
    - name:     {{ golangci_lint_path }}
    - makedirs: True
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     755
golangci-lint:
  file.managed:
    - unless:      command -v {{ golangci_lint_pkg_name }}
    - name:        {{ golangci_lint_temp }}/{{ golangci_lint_script }}
    - source:      https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh
    - makedirs:    True
    - skip_verify: True
    - replace:     False
  cmd.run:
    - unless:   command -v {{ golangci_lint_pkg_name }}
    - name:     sh {{ golangci_lint_script }} -b {{ golangci_lint_path }}
    - cwd:      {{ golangci_lint_temp }}
  {% if grains.cfg_golang.debug.enable %}
golangci-lint-version:
  cmd.run:
    - name:     {{ golangci_lint_path }}/{{ golangci_lint_pkg_name }} --version
  {% endif %}
{% endif %}

