# Install golang and selected go packages
# Install vim-go plugin dependencies

{% set installs = grains.cfg_golang.installs %}
{% set completion = grains.cfg_golang.completion %}

{% if installs and 'golang' in installs %}
  {% set golang_install = 'snap' %}
  {% set snapd_build_required = False %}

  {% if grains.docker %}
    {% set golang_install = 'binary' %}
  {% elif grains.os_family == 'MacOS' %}
    {% set golang_install = 'salt' %}
  {% elif grains.os_family == 'Windows' %}
    {% set golang_install = 'salt' %}
  {% endif %}

  {% if golang_install == 'snap' %}
# Temporary until saltstack releases snapd support
    {% set snapd_build_required = True %}
    {% if grains.cfg_golang.golang.version is defined %}
      {% set golang_channel = grains.cfg_golang.golang.version + '/stable' %}
    {% else %}
      {% set golang_channel = 'stable' %}
    {% endif %}
  {% elif golang_install == 'binary' %}
    {% if grains.cpuarch == 'x86_64' %}
      {% set golang_vers = '1.12.5' %}
      {% set golang_arch = 'amd64' %}
      {% set golang_file = 'go' + golang_vers + '.linux-' + golang_arch + '.tar.gz' %}
      {% set golang_url = 'https://storage.googleapis.com/golang/' + golang_file %}
      {% set golang_hash = 'aea86e3c73495f205929cfebba0d63f1382c8ac59be081b6351681415f4063cf' %}
    {% else %}
      {% set golang_install = 'salt' %}
    {% endif %}
  {% endif %}

  {% if golang_install == 'salt' and not grains.os_family == 'Suse' %}
    {% set golang_pkg_name = 'golang' %}
  {% else %}
    {% set golang_pkg_name = 'go' %}
  {% endif %}

  {% if golang_install == 'snap' %}
    {% set golang_root = '/snap/bin' %}
  {% elif grains.os_family == 'MacOS' %}
    {% set golang_root = '/usr/local/bin' %}
  {% elif golang_install == 'binary' %}
    {% set golang_root = '/usr/local' %}
  {% else %}
    {% set golang_root = '/usr/bin' %}
  {% endif %}

  {% set golang_path = grains.homedir + '/go' %}

  {% if golang_root.endswith('/bin') %}
    {% set golang_exec = golang_root %}
  {% else %}
    {% set golang_exec = golang_root + '/go/bin' %}
  {% endif %}

  {% if snapd_build_required or completion and 'bash' in completion %}
include:
    {% if snapd_build_required %}
  - snapd
    {% endif %}
    {% if completion and 'bash' in completion %}
  - bash
    {% endif %}
  {% endif %}

pr-go-env:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_go_env
    - contents: |
                export GOPATH=$HOME/go
                export PATH=$PATH:$GOPATH/bin
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
append-bashrc-pr_env:
  file.append:
    - name:     {{ grains.homedir }}/.bashrc
    - text:     source $HOME/.pr_go_env
    - require:
      - file:   pr-go-env
golang:
  file.directory:
    - name:     {{ grains.homedir }}/.cache/go-build
    - makedirs: True
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     755
  {% if false %}
# salt barfs on the extraction with UnicodeEncodeError
  archive.extracted:
    - unless:      |
                   test -d {{ golang_root }}/go
                   test -x {{ golang_exec }}/go
    - name:        {{ golang_root }}
    - source:      {{ golang_url }}
    - source_hash: {{ golang_hash }}
    - archive_format: tar
    - tar_options: xzf
  {% elif golang_install == 'binary' %}
  cmd.run:
    - unless:      |
                   test -d {{ golang_root }}/go
                   test -x {{ golang_exec }}/go
    - name:        |
                   curl -LO {{ golang_url }}
                   tar xf {{ golang_file }}
                   mv go {{ golang_root }}
                   rm -f {{ golang_file }}
  {% elif golang_install == 'snap' %}
    {% if snapd_build_required %}
# Temporary until saltstack releases snapd support
  cmd.run:
    - unless:   |
                test -d {{ golang_root }}/go
                test -x {{ golang_exec }}/go
    - name:     snap install go --channel {{ golang_channel }} --classic
    - require:
      - sls:    snapd
    {% else %}
  snap.installed:
    - unless:   |
                test -d {{ golang_root }}/go
                test -x {{ golang_exec }}/go
    - name:     {{ golang_pkg_name }}
    - channel:  {{ golang_channel }}
    {% endif %}
  {% else %}
  pkg.installed:
    {% if grains.os_family == 'MacOS' %}
    - unless:   test -h {{ golang_root }}/go
    {% else %}
    - unless:   |
                test -d {{ golang_root }}/go
                test -x {{ golang_exec }}/go
    {% endif %}
    - name:     {{ golang_pkg_name }}
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
  gocode:       github.com/stamblerre/gocode
  gocomplete:   github.com/posener/complete/gocomplete
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
  swagger:      github.com/go-swagger/go-swagger/cmd/swagger
  dep:          github.com/golang/dep/cmd/dep
  {% endload %}

  {% for key in go_tools %}
    {% if key in installs %}
{{ key }}:
  cmd.run:
    - name:     {{ golang_exec }}/go get {{ go_tools[key] }}
      {# Salt cannot retrieve environment for "runas" on MacOS not being run with sudo #}
      {% if not grains.os_family == 'MacOS' %}
    - runas:    {{ grains.realuser }}
        {# Salt requires sudo for "group" here, so MacOS and Docker excluded #}
        {% if not grains.docker %}
    - group:    {{ grains.realgroup }}
        {% endif %}
      {% endif %}
    - unless:   test -x {{ golang_path }}/bin/{{ key }}
    {% endif %}
  {% endfor %}
{% endif %}

{# Fix for Centos ignoring "runas" above leaving files with owner/group == root/root #}
{% if grains.os_family == 'RedHat' %}
chown-go-path:
  file.directory:
    - name:     {{ golang_path }}
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - recurse:
      - user
      - group
    - require:
      - cmd:    iferr
{% endif %}

# Uses gocomplete package installed above
{% if completion and 'bash' in completion %}
golang-bash-completion:
  cmd.run:
  {# Fix for Centos ignoring "runas" leaving files with owner/group == root/root #}
  {% if grains.os_family == 'RedHat' %}
    - name:     sudo -u {{ grains.realuser }} {{ golang_path }}/bin/gocomplete --install -y
  {% else %}
    - name:     {{ golang_path }}/bin/gocomplete --install -y
  {% endif %}
  {# Salt cannot retrieve environment for "runas" on MacOS not being run with sudo #}
  {% if not grains.os_family == 'MacOS' %}
    - runas:    {{ grains.realuser }}
    {# Salt requires sudo for "group" here, so MacOS and Docker excluded #}
    {% if not grains.docker %}
    - group:    {{ grains.realgroup }}
    {% endif %}
  {% endif %}
  {# gocomplete returns exit code 3 if already installed #}
  {# Suse has version 2018.3.0 of salt without success_retcodes #}
  {% if grains.os_family == 'Suse' %}
    - check_cmd:
      - /bin/true
  {% else %}
    - success_retcodes: 3
  {% endif %}
    - require:
      - sls:    bash
{% endif %}

{% if grains.cfg_golang.debug.enable %}
golang-version:
  cmd.run:
    - name:     {{ golang_exec }}/go version
golang-files:
  cmd.run:
    - name:     ls -l {{ golang_path }}/bin
golang-test:
  file.managed:
    - name:     {{ golang_path }}/src/hello/hello.go
    - source:   {{ grains.stateroot }}/golang/hello.go
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - makedirs: True
  cmd.run:
    - name: |
                cd {{ golang_path}}/src/hello
                {{ golang_exec }}/go build
                ./hello
  {# Salt cannot retrieve environment for "runas" on MacOS not being run with sudo #}
  {% if not grains.os_family == 'MacOS' %}
    - runas:    {{ grains.realuser }}
    {# Salt requires sudo for "group" here, so MacOS and Docker excluded #}
    {% if not grains.docker %}
    - group:    {{ grains.realgroup }}
    {% endif %}
  {% endif %}
{% endif %}
