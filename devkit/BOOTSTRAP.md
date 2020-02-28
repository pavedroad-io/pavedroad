# Bootstrap Detail for the PavedRoad Development Kit

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
The salt state script makes use of the platform's native package installer.
Note that the salt state script is run with _sudo_ privileges on Unix systems
and without _sudo_ privileges on MacOS.
In addition some salt states install binaries directly from the
software website or build the package from source.

See the platform specific information below for the operational differences
in the Unix and MacOS bootstrap scripts.

### Bootstrap Script Options

Both of the bootstrap scripts support the same command line options:

    Usage: bootstrap-<os>.sh [-b <branch>] [-c] [-d] [-s]
        - Option -b <branch> - branch to use for git clone
        - Option -c          - chown command will be skipped
        - Option -d          - debug the salt states
        - Option -s          - salt only will be installed

Note that the chown command is used differently in the Unix and MacOS
bootstrap kits.

See the platform specific information below for differences in the options
in the Unix and MacOS bootstrap scripts.

### Caveats

The bootstrap scripts can issue a large number of INFO and WARNING messages
along with the occasional ERROR message.
Generally all of the WARNING messages can be ignored as most of them
are Python deprecation warnings.
Usually ERROR messages can be ignored as they are a consequence of
either running _salt_ in masterless mode or running in a container.

The bootstrap scripts can fail for a number of reasons:
    - loss of network connectivity
    - servers being down or upgrading
    - mirror misconfiguration
    - installer update incompatibility

The bootstrap scripts have been designed to be run multiple times
in sequence if a temporary glitch has occurred.
Also the salt states will run to completion even if some states fail.

Please report any bootstrap script failures to: [Support](/SUPPORT.md).

## sudo Requirement

The two bootstrap scripts work differently in regards to _sudo_ privileges.
The _sudo_ command allows a user to run a command with root privileges.
SaltStack generally runs the package installer commands native to the platform.
All package installer commands on Linux distributions require _sudo_ privileges.
An exception is when a Linux distro is running in a Docker container.
The _sudo_ command is usually not installed in base Docker containers so
in that case package install commands may be run without _sudo_ privileges.
On MacOS the only install commands that require _sudo_ privileges are those
that install components in system directories.

### Understanding the sudo Command

To see detailed information on the _sudo_ command and the sudoers file:
    - man sudo
    - man sudoers
    - man visudo

To see the _sudo_ privileges for yourself or another user:
    - sudo -l
    - sudo -l -U <username>

Look for a line in the output that includes one of the following:
    - ALL=(ALL)
    - ALL=(ALL) NOPASSWD: ALL

In either case the user will be able to run the bootstrap script.
In the first case the user will have to enter their password on _sudo_ commands.

### Setting up sudo Privileges

A simple way to set up a user with  _sudo_ privileges is to create a
file for the user in the /etc/sudoers.d directory.
The file /etc/sudoers usually includes all of the files in this directory.

The user must have _sudo_ privileges to execute the following commands:
1) visudo /etc/sudoers.d/<username>
    - Enter one of these lines in the file:
    - <username> ALL=(ALL)
    - <username> ALL=(ALL) NOPASSWD: ALL
2) chmod 440 /etc/sudoers.d/<username>

Note that the visudo and sudoedit commands check for correct sudoers format.

See the platform specific information below for _sudo_ privilege differences
in the Unix and MacOS bootstrap scripts.

### Running the Scripts with sudo Privileges

The bootstrap scripts are not expected to be run with the sudo command:
    - bootstrap-unix.sh
    - bootstrap-macos.sh

The salt state script is run with the _sudo_ command by the Unix bootstrap
script but not by the MacOS bootstrap script:
    - bootstrap-unix.sh executes: sudo apply-state.sh
    - bootstrap-macos.sh executes: apply-state.sh

## Unix Bootstrap Specifics

The Unix bootstrap script does the following:

1) checks the user's sudo privileges
2) installs git and either curl or pip
3) uses salt bootstrap script (or apt or pip) to install SaltStack
4) uses git to download the salt states
5) runs apply-state.sh to install the devkit

In order to run bootstrap-unix.sh the user must have the correct _sudo_ privileges
set up to run package installers.
The script checks the _sudo_ privileges for the user and prompts
for a password if necessary.

The Unix bootstrap script then looks for one of the local package installers
to install _salt_ and _git_:
    - apt-get
    - dnf
    - yum
    - zypper

The script then uses git to clone the salt states for the devkit and
runs the salt state script to bootstrap the devkit.

### Caveats

TBD: Explain why two levels of sudo don't work with the unix bootstrap.

TBD: Explain why and how on some systems to install salt and apply states in two steps.

TBD: Detail in Unix section, root owner for everything, etc

### Docker Support

For docker examples of containers initializes with the Unix bootstrap see:
[Dockerfile Examples](/devkit/docker/README.md).

### Vagrant VirtualBox Support

For docker examples of containers initializes with the Unix bootstrap see:
[Vagrantfile Examples](/devkit/vagrant/README.md).

## MacOS Bootstrap Specifics

The MacOS bootstrap script does the following:

1) installs the xcode development tools
2) prepares _/usr/local_ for Homebrew installation
   * later versions of MacOS do not allow the _/usr/local_ directory to be modified
   * the script creates Homebrew directories in _/usr/local_ if they do not exist
   * the script then changes the ownership of these directories to the current user
3) installs Homebrew
4) uses Homebrew to install SaltStack
5) uses git to download the salt states
6) runs apply-state.sh to install the devkit

In order to run bootstrap-macos.sh the user must have the correct _sudo_ privileges
set up to create directories in /usr/local and to change ownership
of directories in /usr/local.
The script prompts for a _sudo_ password if necessary.

The script then uses git to clone the salt states for the devkit and
runs the salt state script to bootstrap the devkit.

The salt state script makes use of the following types of installs:
    - brew install
    - brew cask install
    - binary installs
    - source build installs

### Caveats

TBD: explain MacOS paradigm of non privileged installs

TBD: Explain MacOS system integrity protection & separate data volume in APFS.

TBD: will need to hit return when/if xcode dev tools are installed

TBD: will need to enter password twice, for chown and multipass install

## Salt State Debugging

    - check-state.sh

TBD: Explain some script options and typical examples of usage.


