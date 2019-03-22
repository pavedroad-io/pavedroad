#
# Read the saltenv and then execute states based on that environment
# satenv = dev|stag|test|prod
#

{%- set environment = saltenv %}

{{ environment }}:

    #
    # Thinkgs that get installed on all boxes regardless of 
    # thier role
    #

    'G@environment:{{environment}}':
        - match: compound
        - bash


    #
    # Role specific packages
    #

    'G@environment:{{environment}}' and G@roles:pr-golang:
        - match: compound
        - git
        - golang
        - vim

    # Debian
    'G@os:Debian':
        - debian

    # MacOS
    'G@os:MacOS':
        - macos

    # Windows
    'G@os:Windows':
        - windows
