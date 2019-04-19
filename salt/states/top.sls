#
# Execute states based on the following grains:
# saltenv = dev|stage|test|prod
# os_family = debian|redhat|suse|macos|windows
# roles = pr-golang
# tops = base|bash|git|golang|vim
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

  'G@saltenv:dev and G@roles:pr-golang and G@tops:vim':
    - match: compound
    - vim
