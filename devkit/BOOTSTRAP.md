# Bootstrap Detail for the PavedRoad Development Kit

## Bootstrap Script Operation

The following bootstrap scripts are provided for Unix and MacOS:

    bootstrap-unix.sh
    bootstrap-macos.sh

Both of the bootstrap scripts operate in a similar manner:

1. Install the commands required to bootstrap salt
2. Install the SaltStack package using those commands
3. Clone the salt states for the devkit using git
4. Apply the salt state script to bootstrap the devkit

In particular both bootstrap scripts run the same salt state script:

    apply-state.sh

The salt state script runs in masterless mode and installs a number of
development tool packages along with their man pages and completion scripts.
The salt state script makes use of the platform's native package installer.
Note that the salt state script is run with _sudo_ privileges on Unix systems
and without _sudo_ privileges on MacOS.
In addition some salt states install binaries directly from the
software website or build the package from source.

See the platform specific information below for the operational differences
between the Unix and MacOS bootstrap scripts.

### Bootstrap Script Options

Both of the bootstrap scripts support the same command line options:

    Usage: bootstrap-<os>.sh [-b <branch>] [-c] [-d] [-s]
        - Option -b <branch> - branch to use for git clone
        - Option -c          - chown command will be skipped
        - Option -d          - debug enable on salt states
        - Option -s          - salt only will be installed

Note that the chown command is used differently in the Unix and MacOS
bootstrap scripts.

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
The _sudo_ command allows a user to run a command with _root_ privileges.
SaltStack generally runs the package installer commands native to the platform.
All package installer commands on Linux distributions require _sudo_ privileges.
An exception is when a Linux distro is running in a Docker container.
The _sudo_ command is usually not installed in base Docker containers so
in that case package install commands may be run without _sudo_ privileges.
On MacOS the only install commands that require _sudo_ privileges are those
that install components in system directories.

### Understanding the sudo Command

To see detailed information on the _sudo_ command and the sudoers file:

    man sudo
    man sudoers
    man visudo

To see the _sudo_ privileges for yourself or another user:

    sudo -l
    sudo -l -U <username>

Look for a line in the output that includes one of the following:

    ALL=(ALL)
    ALL=(ALL) NOPASSWD: ALL

In either case the user will be able to run the bootstrap script.
In the first case the user will have to enter their password
when running _sudo_ commands.

### Setting up sudo Privileges

A simple way to set up a user with  _sudo_ privileges is to create a
file for the user in the _/etc/sudoers.d_ directory.
The file _/etc/sudoers_ usually includes all of the files in this directory.

The user must have _sudo_ privileges to execute _visudo_ and _chmod_ 
to set up any user with _sudo_ privileges.
Replace \<username\> with the actual user name in the following commands:

```
visudo /etc/sudoers.d/<username>
```
    
Enter one of these lines in the file:

- \<username\> ALL=(ALL)
- \<username\> ALL=(ALL) NOPASSWD: ALL

Then change the mode of the file:

```
chmod 440 /etc/sudoers.d/<username>
```

Note that the _visudo_ and _sudoedit_ commands check for correct _sudoers_ format.

See the platform specific information below for _sudo_ privilege differences
in the Unix and MacOS bootstrap scripts.

### Running the Scripts with sudo Privileges

The bootstrap scripts are not expected to be run with the sudo command:

    bootstrap-unix.sh
        -or-
    bootstrap-macos.sh

The salt state script is run with the _sudo_ command by the Unix bootstrap
script but not by the MacOS bootstrap script:

- bootstrap-unix.sh executes the salt sates as follows:

        sudo apply-state.sh
    
- bootstrap-macos.sh executes the salt sates as follows:

        apply-state.sh

## Unix Bootstrap Specifics

The Unix bootstrap script performs the following tasks:

1. Checks the user's sudo privileges

 In order to run bootstrap-unix.sh the user must have the correct
 _sudo_ privileges set up to run package installers.
 The script checks the _sudo_ privileges for the user and prompts
 for a password if necessary.

2. Installs git and either curl or pip

 The Unix bootstrap script then looks for one of the local package installers
 to install _git_ and either _curl_ or _pip_ as needed to install salt:
 - apt-get
 - dnf
 - yum
 - zypper
3. Installs SaltStack using the salt bootstrap script (or apt-get or pip)

        curl -o install_salt.sh -L https://bootstrap.saltstack.com
        sudo sh install_salt.sh -d -P -X
            -or-
        sudo apt-get -y -qq install salt-common
            -or-
        sudo pip3 install salt
4. Downloads the salt states using git

        git clone https://github.com/pavedroad-io/pavedroad.git /tmp
5. Applies the salt states to install the devkit

        sudo /tmp/devkit/apply-state.sh
6. Changes the ownership to the user of all files in the user's home directory

        homedir=$(eval echo ~$(id -un))
        $sudo chown -R $(id -un):$(id -gn) ${homedir}
    When executing the Unix bootstrap script the chown step
    may be skipped as follows:

        bootstrap-unix.sh -c

### Caveats

The salt state script must be run with _sudo_ privileges with few exceptions
such as MacOS and Linux in a Docker container without _sudo_ installed.
However, this must not be a nested execution of _sudo_ as the script needs
to ascertain the real user and group IDs and the correct home directory.
Thus the bootstrap script cannot be run with _sudo_ privileges as
it uses _sudo_ to execute the salt state script.
If the bootstrap script is run with _sudo_ privileges then incorrect
user and group IDs will be used as well as the wrong home directory.

Some salt states on some platforms create files with incorrect ownership.
Thus the last step in the Unix bootstrap script performs a workaround by
changing the ownership of all files recursively in the user's home directory.
However, on a pre-existing system this action may not be preferred.
In this case this _chown_ step may be skipped but the user
should look for newly installed files that have _root_ ownership.

### Docker Support

For examples of Dockerfiles that build Docker container images
by running the Unix bootstrap see: [Dockerfile Examples](/devkit/docker/README.md).

### Vagrant VirtualBox Support

For examples of Vagrantfiles that provision Vagrant VirtualBox images
with the Unix bootstrap see: [Vagrantfile Examples](/devkit/vagrant/README.md).

## MacOS Bootstrap Specifics

### Installing Developer Packages on MacOS

The salt state script for MacOS makes use of the following types
of installations:

- brew install
- brew cask install
- binary installs
- source build installs

In general _sudo_ privileges are required to install packages
in MacOS system directories.
The MacOS platform has evolved over time to increase protection from the
installation of malicious applications.
Some examples of this are:

- El Capitan - System Integrity Protection
- High Sierra - The /usr/local directory is protected
- Catalina - APFS hidden data volume protection

MacOS does not allow the ownership or permissions of the
_/usr/local_ directory to be modified even with _sudo_ privileges
as of the release of High Sierra.
However using _sudo_ privileges a user may create subdirectories in the
_/usr/local_ directory and may modify those created directories.

Many developers prefer to perform Homebrew installations in _/usr/local_
without _sudo_ privileges.
To enable this the MacOS bootstrap script sets up the _/usr/local_ directory
properly by by creating all of the directories required by Homebrew in
_/usr/local_ and changing the ownership of those directories to the user.
Thus the user must have the correct _sudo_ privileges to run
the bootstrap script but once _/usr/local_ is set up then
Homebrew can be run without _sudo_ privileges.

However this only applies to installations from source:

    brew install <package>

Some binary packages may be installed in system directories and require
_sudo_ privileges.
Homebrew binary installations are performed like this: 

    brew cask install <package>

### Executing the MacOS Bootstrap Script

The MacOS bootstrap script performs the following tasks:

1. Prepares _/usr/local_ for Homebrew installation

    The script prompts for a _sudo_ password at this point if necessary.
    When executing the MacOS bootstrap script this chown step
    may be skipped as follows:

        bootstrap-macos.sh -c
2. Installs Homebrew by downloading and running a ruby script

        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
3. Installs the Xcode development tools

    Later versions of the Homebrew install script include installation
    of the Xcode developer tools.
    The developer tools will be installed separately if they are not installed
    along with Homebrew.
4. Installs SaltStack using Homebrew

        brew install saltstack
5. Downloads the salt states using git

        git clone https://github.com/pavedroad-io/pavedroad.git /tmp
6. Applies the salt states to install the devkit

        sh /tmp/devkit/apply-state.sh

### Caveats

The MacOS bootstrap script will pause before installing the Xcode developer
tools and the user will need to hit return to proceed.

If the user does not have _sudo_ privileges that do not require a password
then the user will need to enter their password twice,
once for setting up _/usr/local_ and once for the installation of _multipass_.

Sometimes a salt state may appear to have failed but the application was
successfully install.
This usually occurs due to a version mismatch between salt, Homebrew,
or the application.
The mismatch is due to an added suffix to the version that was requested
to be installed.

## Salt State Debugging

The following script is provided to debug salt states:

    check-state.sh

To see all of the options and states available execute the command as follows:

    check-state.sh -u

A typical example would be to run a single salt state to install an
application like _vim_ after setting the salt grains.

On Unix systems other than MacOS _sudo_ is required to run salt states:

    sudo check-state.sh -G vim
    
On MacOS _sudo_ is not required to run salt states:

    check-state.sh -G vim

In Docker containers where _sudo_ is not installed it is not required
to run the script.


