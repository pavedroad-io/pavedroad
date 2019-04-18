#
# Execute states based on the following grains:
# saltenv = dev|stage|test|prod
# os =  debian|macos|windows
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
  'G@os:Debian and G@tops:debian':
    - match: compound
    - debian

# MacOS
  'G@os:MacOS and G@tops:macos':
    - match: compound
    - macos

# Windows
  'G@os:Windows and G@tops.windows':
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

  'G@saltenv:dev and G@roles:pr-golang and G@tops:git':
    - match: compound
    - git

  'G@saltenv:dev and G@roles:pr-golang and G@tops:golang':
    - match: compound
    - golang

  'G@saltenv:dev and G@roles:pr-golang and G@tops:vim':
    - match: compound
    - vim
