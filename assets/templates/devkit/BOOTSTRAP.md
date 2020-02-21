# Bootstrap Detail for the {{organization}} {{project}}

## Bootstrap Script Operation

The following bootstrap scripts are provided for Unix and MacOS:
    - bootstrap-unix.sh
    - bootstrap-macos.sh

Both of the bootstrap scripts operate in a similar manner:
1) install the commands required to bootstrap salt
2) run those commands to install the salt package
3) use git to clone the salt states for the devkit
4) run salt state script to bootstrap the devkit

In particular both bootstrap scripts run the same salt state script:
    - apply-state.sh

The salt state script runs in masterless mode and installs a number of
development tool packages along with their man pages and completion scripts.
Note that the salt state script is run with _sudo_ privileges on Unix systems
and without _sudo_ privileges on MacOS.

See the specific information below for the operational differences
in the Unix and MacOS bootstrap scripts.

## Bootstrap Script Options

Both of the bootstrap scripts support the same command line options:

    Usage: bootstrap-<os>.sh [-b <branch>] [-c] [-d] [-s]
        - Option -b <branch> - branch to use for git clone
        - Option -c          - chown command will be skipped
        - Option -d          - debug the salt states
        - Option -s          - salt only will be installed

Note that the chown command is used differently in the Unix and MacOS
bootstrap kits.

See the specific information below for differences in the options
in the Unix and MacOS bootstrap scripts.

## sudo Requirement

The two bootstrap scripts work differently in regards to _sudo_ privileges.
The _sudo_ command allows a user to run a command with root privileges.
All package install commands on Linux distributions require _sudo_ privileges.
An exception is when a Linux distro is running in a Docker container.
The _sudo_ command is usually not installed in base Docker containers so
in that case package install commands may be run without _sudo_ privileges.
On MacOS the only install commands that require _sudo_ privileges are those
that install components in system directories.

- sudo -l
- sudo -l -U username
- /etc/sudoers.d/username
- username ALL=(ALL) NOPASSWD: ALL
- chmod 440
- visudo and sudoedit check for correct format

TBD: Go into detail about how sudo is used and why correct privileges are needed.

TBD: Explain why and how on some systems to install salt and apply states in two steps.

TBD: Detail in Unix section, root owner for everything, etc

See the specific information below for _sudo_ privilege differences
in the Unix and MacOS bootstrap scripts.

## Unix Bootstrap Specifics

TBD: Explain why two levels of sudo don't work with the unix bootstrap.

In order to run bootstrap-unix.sh the user must have the correct sudo privileges
set up to install packages.
The script checks the sudo privileges for the user and prompts for a password if necessary.

The unix bootstrap script does the following:

TBD: Go into more detail on these steps.

1) checks sudo privileges
2) installs git and either curl or pip
3) uses salt bootstrap script (or apt or pip) to install SaltStack
4) uses git to download the salt states
5) runs apply-state.sh to install the devkit

## MacOS Bootstrap Specifics

TBD: Explain MacOS system integrity protection and separate data volume in APFS.

TBD: will need to hit return when/if xcode dev tools are installed

In order to run bootstrap-macos.sh the user must have the correct sudo privileges
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
