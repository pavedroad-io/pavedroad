#
# Execute states based on the following grains:
# saltenv = dev|stage|test|prod
# os_family = debian|redhat|suse|macos|windows
# roles = pr-golang
# tops = specify options for each salt state
#

{{ saltenv }}:

#
# Packages that get installed on all boxes regardless
#

  'G@tops:base':
    - match: compound
    - base

#
# OS specific packages
#

# Debian
  'G@os_family:Debian and G@tops:debian':
    - match: compound
    - debian

# RedHat
  'G@os_family:RedHat and G@tops:redhat':
    - match: compound
    - redhat

# Suse
  'G@os_family:Suse and G@tops:suse':
    - match: compound
    - suse

# MacOS
  'G@os_family:MacOS and G@tops:macos':
    - match: compound
    - macos

# Windows
  'G@os_family:Windows and G@tops.windows':
    - match: compound
    - windows

#
# Environment specific packages
#

  'G@saltenv:dev and G@tops:bash':
    - match: compound
    - bash

  'G@saltenv:dev and G@tops:zsh':
    - match: compound
    - zsh

#
# Role specific packages
#

  'G@saltenv:dev and G@roles:pr-golang and G@tops:docker':
    - match: compound
    - docker

  'G@saltenv:dev and G@roles:pr-golang and G@tops:git':
    - match: compound
    - git

  'G@saltenv:dev and G@roles:pr-golang and G@tops:golang':
    - match: compound
    - golang

# vim.sls depends on files installed by golang.sls
  'G@saltenv:dev and G@roles:pr-golang and G@tops:vim':
    - match: compound
    - vim

  'G@saltenv:dev and G@roles:pr-golang and G@tops:microk8s':
    - match: compound
    - microk8s

  'G@saltenv:dev and G@roles:pr-golang and G@tops:multipass':
    - match: compound
    - multipass

  'G@saltenv:dev and G@roles:pr-golang and G@tops:graphviz':
    - match: compound
    - graphviz

  'G@saltenv:dev and G@roles:pr-golang and G@tops:kompose':
    - match: compound
    - kompose

  'G@saltenv:dev and G@roles:pr-golang and G@tops:kubebuilder':
    - match: compound
    - kubebuilder

  'G@saltenv:dev and G@roles:pr-golang and G@tops:kubectl':
    - match: compound
    - kubectl

  'G@saltenv:dev and G@roles:pr-golang and G@tops:kustomize':
    - match: compound
    - kustomize

  'G@saltenv:dev and G@roles:pr-golang and G@tops:nodejs':
    - match: compound
    - nodejs

  'G@saltenv:dev and G@roles:pr-golang and G@tops:pretty-swag':
    - match: compound
    - pretty-swag

  'G@saltenv:dev and G@roles:pr-golang and G@tops:skaffold':
    - match: compound
    - skaffold

  'G@saltenv:dev and G@roles:pr-golang and G@tops:direnv':
    - match: compound
    - direnv

  'G@saltenv:dev and G@roles:pr-golang and G@tops:roadctl':
    - match: compound
    - roadctl

  'G@saltenv:dev and G@roles:pr-golang and G@tops:ctags':
    - match: compound
    - ctags

  'G@saltenv:dev and G@roles:pr-golang and G@tops:jq':
    - match: compound
    - jq

  'G@saltenv:dev and G@roles:pr-golang and G@tops:ripgrep':
    - match: compound
    - ripgrep

# fzf.sls depends on files installed by vim.sls
  'G@saltenv:dev and G@roles:pr-golang and G@tops:fzf':
    - match: compound
    - fzf

  'G@saltenv:dev and G@roles:pr-golang and G@tops:fossa':
    - match: compound
    - fossa
