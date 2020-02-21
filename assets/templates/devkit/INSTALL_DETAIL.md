# Bootstrap Detail for the {{organization}} {{project}}

## Bootstrap Script Options

Both of the following scripts support the same command line options:

    - bootstrap-unix.sh
    - bootstrap-macos.sh

    Usage: bootstrap-<os>.sh [-b <branch>] [-c] [-d] [-s]
        - Option -b <branch> - git clone
        - Option -c          - chown skip
        - Option -d          - debug states
        - Option -s          - salt only

TBD: Be more specific on options.

## Bootstrap Script Operation

TBD: Go into detail on how the scripts work.

    - apply-state.sh

## sudo Requirement

TBD: Go into detail about how sudo is used and why correct permission is needed.

TBD: Explain why and how on some systems to install salt and apply states in two steps.

## Unix Bootstrap Specifics

TBD: Explain why two levels of sudo don't work with the unix bootstrap.

In order to run bootstrap-unix.sh the user must have the correct sudo permission
set up to install packages.
The script checks the sudo permission for the user and prompts for a password if necessary.

The unix bootstrap script does the following:

TBD: Go into more detail on these steps.

1) checks sudo permission
2) installs git and either curl or pip
3) uses salt bootstrap script (or apt or pip) to install SaltStack
4) uses git to download the salt states
5) runs apply-state.sh to install the devkit

## MacOS Bootstrap Specifics

TBD: Explain MacOS system integrity protection.

In order to run bootstrap-macos.sh the user must have the correct sudo permission
set up to create directories in /usr/local and to change ownership of directories in /usr/local.
The script prompts for a sudo password if necessary.

The MacOS bootstrap script does the following:

TBD: Go into more detail on these steps.

1) installs the xcode development tools
2) prepares _/usr/local_ for Homebrew installation

   * later versions of MacOS do not allow the _/usr/local_ directory to be modified
   * the script creates Homebrew directories in _/usr/local_ if they do not exist
   * the script then changes the ownership of these directories to the current user
3) installs Homebrew
4) uses Homebrew to install SaltStack
5) uses git to download the salt states
6) runs apply-state.sh to install the devkit

## Salt State Debugging

    - check-state.sh

TBD: Explain script options and typical examples of usage.

{% include 'footer.md' %}
