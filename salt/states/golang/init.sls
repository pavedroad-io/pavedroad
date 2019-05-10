# Install golang

{% set installs = grains.cfg_golang.installs %}

{% if installs %}
  {% if 'golang' in installs %}
golang:
  pkg.installed:
    {% if grains.os_family == 'Suse' %}
    - name:     go
    {% else %}
    - name:     golang
    {% endif %}
    {% if grains.cfg_golang.golang.version is defined %}
    - version:  {{ grains.cfg_golang.golang.version }}
    {% endif %}
  {% endif %}

  {% load_yaml as go_tools %}
  godep:        github.com/tools/godep
  dlv:          github.com/go-delve/delve/cmd/dlv
  golint:       github.com/golang/lint/golint
  gosec:        github.com/securego/gosec/cmd/gosec
  {% endload %}

  {% for key in go_tools %}
    {% if key in installs %}
{{ key }}:
  cmd.run:
    - name: go get {{ go_tools[key] }}
    {% endif %}
  {% endfor %}
{% endif %}

{% if grains.cfg_golang.debug.enable %}
golang-test:
  file.managed:
    - name:     {{ grains.homedir }}/go/src/hello/hello.go
    - source:   {{ grains.stateroot }}/golang/hello.go
    - user:     {{ grains.username }}
    - makedirs: True
  cmd.run:
    - name: |
                cd $HOME/go/src/hello
                go build
                ./hello
{% endif %}
