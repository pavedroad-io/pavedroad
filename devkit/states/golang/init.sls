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
  {% elif grains.os == 'Fedora' %}
    {% set golang_install = 'binary' %}
  {% endif %}

  {% if golang_install == 'binary' %}
    {% if (grains.os == 'Ubuntu' and grains.osmajorrelease < 20) or
      (grains.os == 'CentOS' and grains.osmajorrelease < 8) or
      (grains.os == 'Fedora' and grains.osmajorrelease < 30) or
      (grains.os_family == 'Suse' and grains.osfullname == 'Leap' and
        (grains.osrelease | float) < 15.1) %}
      {# For systems where salt state archive.extracted gets a unicode error #}
      {% set golang_install = 'manual' %}
    {% endif %}
  {% endif %}

  {% if golang_install == 'snap' %}
    {# Temporary fix until saltstack releases snap.installed state support #}
    {% set snapd_build_required = True %}
    {% if grains.cfg_golang.golang.version is defined %}
      {% set golang_channel = grains.cfg_golang.golang.version + '/stable' %}
    {% else %}
      {% set golang_channel = 'stable' %}
    {% endif %}
  {% elif golang_install == 'binary' or golang_install == 'manual' %}
    {% if grains.cpuarch == 'x86_64' %}
      {% set version = salt.cmd.run('curl -s https://golang.org/VERSION?m=text') %}
      {% set golang_arch = 'amd64' %}
      {% set golang_file = version + '.linux-' + golang_arch + '.tar.gz' %}
      {% set golang_url = 'https://storage.googleapis.com/golang/' + golang_file %}
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
  {% elif golang_install == 'binary' or golang_install == 'manual' %}
    {% set golang_root = '/usr/local' %}
    {% set golang_temp = salt.temp.dir() %}
  {% else %}
    {% set golang_root = '/usr/bin' %}
  {% endif %}

  {% set golang_path = grains.homedir + '/go' %}
  {% set golang_bin = golang_path + '/bin' %}

  {% if golang_root.endswith('/bin') %}
    {% set golang_exec = golang_root %}
  {% else %}
    {% set golang_exec = golang_root + '/go/bin' %}
  {% endif %}

  {% if snapd_build_required %}
include:
  - snapd
  {% endif %}

pr-go-aliases:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_go_aliases
    - source:   salt://golang/pr_go_aliases
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if grains.saltrun == 'install' %}
    - replace:     False
  {% endif %}
pr-go-env:
  file.managed:
    - name:     {{ grains.homedir }}/.pr_go_env
    - contents: |
                export GOPATH=$HOME/go
  {% if golang_install == 'binary' %}
                export PATH=$PATH:{{ golang_exec }}:$GOPATH/bin
  {% else %}
                export PATH=$PATH:$GOPATH/bin
  {% endif %}
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     644
  {% if grains.saltrun == 'install' %}
    - replace:     False
  {% endif %}
go-append-pr_bashrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     |
                source $HOME/.pr_go_aliases
                source $HOME/.pr_go_env
    - require:
      - file:   pr-go-aliases
      - file:   pr-go-env
go-append-pr_zshrc:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     |
                source $HOME/.pr_go_aliases
                source $HOME/.pr_go_env
    - require:
      - file:   pr-go-aliases
      - file:   pr-go-env
golang-cache:
  file.directory:
    - name:     {{ grains.homedir }}/.cache/go-build
    - makedirs: True
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     755
  {% if grains.saltrun == 'install' %}
    - unless:   command -v {{ golang_exec }}/go
  {% endif %}
  {% if golang_install == 'binary' %}
golang-binary:
  archive.extracted:
    - name:           {{ golang_root }}
    - source:         {{ golang_url }}
    - archive_format: tar
    - options:        v
    - skip_verify:    True
    - unless:         |
                      test -d {{ golang_root }}/go
    {% if grains.saltrun == 'install' %}
                      test -x {{ golang_exec }}/go
    {% endif %}
  {# Old salt versions barf on the tar extraction with UnicodeEncodeError: #}
  {#    'ascii' codec can't encode character u'\xc4' in position 44: #}
  {#       ordinal not in range(128) #}
  {# Temporary workaround is to curl tar file manually and extract #}
  {% elif golang_install == 'manual' %}
golang-manual:
  cmd.run:
    - name:     |
                curl -LO {{ golang_url }}
                tar xf {{ golang_file }}
                mv go {{ golang_root }}
                rm -f {{ golang_file }}
    - cwd:      {{ golang_temp }}
    - unless:   |
                test -d {{ golang_root }}/go
    {% if grains.saltrun == 'install' %}
                test -x {{ golang_exec }}/go
    {% endif %}
  {% elif golang_install == 'snap' %}
golang-snap:
    {% if snapd_build_required %}
    {# Temporary workaround until saltstack releases snapd support #}
  cmd.run:
    - name:     snap install go --channel {{ golang_channel }} --classic
    - require:
      - sls:    snapd
    - unless:   |
                test -d {{ golang_root }}/go
      {% if grains.saltrun == 'install' %}
                test -x {{ golang_exec }}/go
      {% endif %}
    {% else %}
  snap.installed:
    - name:     {{ golang_pkg_name }}
    - channel:  {{ golang_channel }}
    - unless:   |
                test -d {{ golang_root }}/go
      {% if grains.saltrun == 'install' %}
                test -x {{ golang_exec }}/go
      {% endif %}
    {% endif %}
  {% else %}
golang-package:
    {% if grains.saltrun == 'upgrade' %}
  pkg.removed:
    - name:     {{ golang_pkg_name }}
golang-install:
    {% endif %}
  pkg.installed:
    - name:     {{ golang_pkg_name }}
    - unless:   |
    {% if grains.os_family == 'MacOS' %}
                test -h {{ golang_root }}/go
    {% else %}
                test -d {{ golang_root }}/go
    {% endif %}
    {% if grains.saltrun == 'install' %}
                test -x {{ golang_exec }}/go
    {% endif %}
    {% if grains.cfg_golang.golang.version is defined %}
    - version:  {{ grains.cfg_golang.golang.version }}
    {% endif %}
  {% endif %}
golang-bin:
  file.directory:
    - name:     {{ golang_bin }}
    - makedirs: True
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - mode:     755

  {% load_yaml as go_tools %}
  asmfmt:        github.com/klauspost/asmfmt/cmd/asmfmt
  dlv:           github.com/go-delve/delve/cmd/dlv
  errcheck:      github.com/kisielk/errcheck
  fillstruct:    github.com/davidrjenni/reftools/cmd/fillstruct
  gocomplete:    github.com/posener/complete/gocomplete
  godef:         github.com/rogpeppe/godef
  godep:         github.com/tools/godep
  godepgraph:    github.com/kisielk/godepgraph
  gogetdoc:      github.com/zmb3/gogetdoc
  goimports:     golang.org/x/tools/cmd/goimports
  golangci-lint: github.com/golangci/golangci-lint/cmd/golangci-lint
  golint:        golang.org/x/lint/golint
  gomodifytags:  github.com/fatih/gomodifytags
  gopls:         golang.org/x/tools/gopls
  gorename:      golang.org/x/tools/cmd/gorename
  gosec:         github.com/securego/gosec/cmd/gosec
  gotags:        github.com/jstemmer/gotags
  govendor:      github.com/kardianos/govendor
  guru:          golang.org/x/tools/cmd/guru
  iferr:         github.com/koron/iferr
  impl:          github.com/josharian/impl
  keyify:        honnef.co/go/tools/cmd/keyify
  modgraphviz:   golang.org/x/exp/cmd/modgraphviz
  motion:        github.com/fatih/motion
  staticcheck:   honnef.co/go/tools/cmd/staticcheck
  swagger:       github.com/go-swagger/go-swagger/cmd/swagger
  yq:            github.com/mikefarah/yq/v4
  {% endload %}

  {% for key in go_tools %}
    {% if key in installs %}
{{ key }}:
  {# go install with explicit version allows tools to be installed without modules #}
  cmd.run:
    - name:     {{ golang_exec }}/go install {{ go_tools[key] }}@latest
      {# Salt cannot retrieve environment for "runas" on MacOS not being run with sudo #}
      {% if not grains.os_family == 'MacOS' %}
    - runas:    {{ grains.realuser }}
        {# Salt requires sudo for "group" here, so MacOS and Docker excluded #}
        {% if not grains.docker %}
    - group:    {{ grains.realgroup }}
        {% endif %}
      {% endif %}
      {% if grains.saltrun == 'install' %}
    - unless:   test -x {{ golang_bin }}/{{ key }}
      {% endif %}
    {% endif %}
  {% endfor %}
{% endif %}

{# dep and gometalinter no longer build so binary install scripts are grabbed and run #}
dep:
  cmd.run:
    - name:     curl https://raw.githubusercontent.com/golang/dep/master/install.sh\
                | PATH={{ golang_exec }}:$PATH bash
{% if grains.saltrun == 'install' %}
    - unless:   command -v {{ golang_bin }}/dep
{% endif %}
gometalinter:
  cmd.run:
    - name:     curl -L https://git.io/vp6lP | BINDIR={{ golang_bin }} bash
{% if grains.saltrun == 'install' %}
    - unless:   command -v {{ golang_bin }}/gometalinter
{% endif %}
{# exception: install of revive@latest fails silently if GOPATH is not set #}
revive:
  cmd.run:
    - name:     GOPATH={{ golang_path }} {{ golang_exec }}/go install github.com/mgechev/revive@latest
{% if grains.saltrun == 'install' %}
    - unless:   command -v {{ golang_bin }}/revive
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

{# Completion uses gocomplete package installed above #}
{# Appends complete command lines to .pr_bashrc and .pr_zshrc #}
{# Assume this overrides normal completion installed for bash and zsh #}
{% if completion and 'gocomplete' in completion %}
gocomplete-bash-completion:
  file.append:
    - name:     {{ grains.homedir }}/.pr_bashrc
    - text:     complete -C $HOME/go/bin/gocomplete go
gocomplete-zsh-completion:
  file.append:
    - name:     {{ grains.homedir }}/.pr_zshrc
    - text:     |
                autoload -U +X bashcompinit && bashcompinit
                complete -o nospace -C $HOME/go/bin/gocomplete go
{% endif %}
{% if completion and 'zsh-go' in completion %}
zchee-zsh-completion:
  {% set golang_temp_dir = salt.temp.dir() %}
  git.latest:
    - name:        https://github.com/zchee/zsh-completions.git
    - branch:      master
    - target:      {{ golang_temp_dir }}/zchee
    - force_clone: True
  file.copy:
    - name:     {{ pillar.directories.completions.zsh_go }}
    - source:   {{ golang_temp_dir }}/zchee/src/go
    - makedirs: True
{% endif %}

{% if grains.cfg_golang.debug.enable %}
golang-version:
  cmd.run:
    - name:     {{ golang_exec }}/go version
golang-files:
  cmd.run:
    - name:     ls -l {{ golang_bin }}
golang-test:
  file.managed:
    - name:     {{ golang_path }}/src/hello/hello.go
    - source:   salt://golang/hello.go
    - user:     {{ grains.realuser }}
    - group:    {{ grains.realgroup }}
    - makedirs: True
  cmd.run:
    - cwd:      {{ golang_path}}/src/hello
    - name: |
                {{ golang_exec }}/go mod init hello
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
