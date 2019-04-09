#
# Read the saltenv and then execute states based on that environment
# saltenv = dev|stag|test|prod
#

{{ saltenv }}:

    #
    # Things that get installed on all boxes regardless of 
    # their role
    #

    'G@saltenv:dev':
        - match: compound
        - bash

    #
    # Role specific packages
    #

    'G@saltenv:dev and G@roles:pr-golang':
        - match: compound
        - git
        - golang
        - vim

    #
    # OS specific packages
    #

    # Debian
    'G@os:Debian':
        - debian

    # MacOS
    'G@os:MacOS':
        - macos

    # Windows
    'G@os:Windows':
        - windows
