base:
    # All environments
    '*':
        - bash
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
