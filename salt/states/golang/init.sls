# Install golang and selected go packages
# Install vim-go plugin dependencies

{% set installs = grains.cfg_golang.installs %}

{% if installs %}
  {% if 'golang' in installs %}
golang:
  pkg.installed:
    - unless:   command -v go
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
  golint:       golang.org/x/lint/golint
  gosec:        github.com/securego/gosec/cmd/gosec
  asmfmt:       github.com/klauspost/asmfmt/cmd/asmfmt
  errcheck:     github.com/kisielk/errcheck
  fillstruct:   github.com/davidrjenni/reftools/cmd/fillstruct
  gocode:       github.com/mdempsky/gocode
  gocode-gomod: github.com/stamblerre/gocode
  godef:        github.com/rogpeppe/godef
  gogetdoc:     github.com/zmb3/gogetdoc
  goimports:    golang.org/x/tools/cmd/goimports
  gopls:        golang.org/x/tools/cmd/gopls
  gometalinter: github.com/alecthomas/gometalinter
  golangci-lint: github.com/golangci/golangci-lint/cmd/golangci-lint
  gomodifytags: github.com/fatih/gomodifytags
  gorename:     golang.org/x/tools/cmd/gorename
  gotags:       github.com/jstemmer/gotags
  guru:         golang.org/x/tools/cmd/guru
  impl:         github.com/josharian/impl
  keyify:       honnef.co/go/tools/cmd/keyify
  motion:       github.com/fatih/motion
  iferr:        github.com/koron/iferr
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
