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

  'G@tops:base and G@saltrun:install':
    - match: compound
    - base

#
# OS specific packages
#

# Debian
  'G@os_family:Debian and G@tops:debian and G@saltrun:install':
    - match: compound
    - debian

# RedHat
  'G@os_family:RedHat and G@tops:redhat and G@saltrun:install':
    - match: compound
    - redhat

# Suse
  'G@os_family:Suse and G@tops:suse and G@saltrun:install':
    - match: compound
    - suse

# MacOS
  'G@os_family:MacOS and G@tops:macos and G@saltrun:install':
    - match: compound
    - macos

# Windows
  'G@os_family:Windows and G@tops.windows and G@saltrun:install':
    - match: compound
    - windows

#
# Environment specific packages
#

  'G@tops:bash and G@saltrun:install':
    - match: compound
    - bash

  'G@tops:zsh and G@saltrun:install':
    - match: compound
    - zsh

#
# Role specific packages
#

  'G@tops:docker and G@saltrun:install':
    - match: compound
    - docker

  'G@tops:git and G@saltrun:install':
    - match: compound
    - git

  'G@tops:golang and G@saltrun:(install|upgrade)':
    - match: compound
    - golang

# vim.sls depends on files installed by golang.sls
  'G@tops:vim and G@saltrun:install':
    - match: compound
    - vim

  'G@tops:microk8s and G@saltrun:install':
    - match: compound
    - microk8s

  'G@tops:multipass and G@saltrun:install':
    - match: compound
    - multipass

  'G@tops:graphviz and G@saltrun:install':
    - match: compound
    - graphviz

  'G@tops:kompose and G@saltrun:install':
    - match: compound
    - kompose

  'G@tops:kubebuilder and G@saltrun:install':
    - match: compound
    - kubebuilder

  'G@tops:kubectl and G@saltrun:install':
    - match: compound
    - kubectl

  'G@tops:kustomize and G@saltrun:install':
    - match: compound
    - kustomize

  'G@tops:nodejs and G@saltrun:install':
    - match: compound
    - nodejs

  'G@tops:pretty_swag and G@saltrun:install':
    - match: compound
    - pretty-swag

  'G@tops:skaffold and G@saltrun:install':
    - match: compound
    - skaffold

  'G@tops:direnv and G@saltrun:install':
    - match: compound
    - direnv

  'G@tops:roadctl and P@saltrun:(install|upgrade)':
    - match: compound
    - roadctl

  'G@tops:ctags and G@saltrun:install':
    - match: compound
    - ctags

  'G@tops:jq and G@saltrun:install':
    - match: compound
    - jq

  'G@tops:ripgrep and G@saltrun:install':
    - match: compound
    - ripgrep

# fzf.sls depends on files installed by vim.sls
  'G@tops:fzf and G@saltrun:install':
    - match: compound
    - fzf

  'G@tops:fossa and G@saltrun:install':
    - match: compound
    - fossa

  'G@tops:stern and G@saltrun:install':
    - match: compound
    - stern

  'G@tops:tilt and G@saltrun:install':
    - match: compound
    - tilt

  'G@tops:sonar_scanner and G@saltrun:install':
    - match: compound
    - sonar-scanner
