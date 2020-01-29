# Install ripgrep

{% set installs = grains.cfg_ripgrep.installs %}
{% set completion = grains.cfg_ripgrep.completion %}

{% if installs and 'ripgrep' in installs %}
  {% set ripgrep_pkg_name = 'ripgrep' %}
  {% set ripgrep_bin_name = 'rg' %}
  {% set ripgrep_path_name = '/usr/bin/' %}
  {% set ripgrep_snap_install = False %}
  {% if not grains.docker and (grains.os == 'Ubuntu' and grains.osmajorrelease >= 19) %}
    {% set ripgrep_snap_install = True %}
    {% set ripgrep_path_name = '/snap/bin/' %}
  {% endif %}

  {% if ripgrep_snap_install %}
include:
  - snapd
  {% endif %}

ripgrep:
  {% if ripgrep_snap_install %}
  cmd.run:
    - require:
      - sls:    snapd
    - unless:   snap list | grep {{ ripgrep_pkg_name }}
    - name:     snap install {{ ripgrep_pkg_name }} --classic
  {% else %}
    {% if grains.os_family in ('Debian', 'RedHat', 'Suse') 
      and not (grains.os == 'Ubuntu' and grains.osmajorrelease >= 19) %}
  pkgrepo.managed:
      {% if grains.os_family == 'Debian' %}
    - ppa:      x4121/ripgrep
      {% elif grains.os == 'CentOS' and grains.osmajorrelease == 7 %}
    - humanname:           Copr repo for ripgrep from carlwgeorge
    - baseurl:             https://copr-be.cloud.fedoraproject.org/results/carlwgeorge/ripgrep/epel-7-{{ grains.cpuarch }}/
    - type:                rpm-md
    - skip_if_unavailable: True
    - gpgcheck:            1
    - gpgkey:              https://copr-be.cloud.fedoraproject.org/results/carlwgeorge/ripgrep/pubkey.gpg
    - repo_gpgcheck:       0
    - enabled:             1
    - enabled_metadata:    1
      {% elif grains.os_family == 'Suse' and grains.osfullname == 'Leap' %}
    - humanname: Main open source software repository (openSUSE_Leap_15.1)
    - baseurl:   http://download.opensuse.org/distribution/leap/15.1/repo/oss/
    - type:      rpm-md
    - enabled:   1
      {% endif %}
    - require_in:
      - pkg:    ripgrep
    {% endif %}
  pkg.installed:
    - unless:   command -v {{ ripgrep_bin_name }}
    - name:     {{ ripgrep_pkg_name }}
    {% if grains.cfg_ripgrep.ripgrep.version is defined %}
    - version:  {{ grains.cfg_ripgrep.ripgrep.version }}
    {% endif %}
  {% endif %}

  {% if completion %}
    {# bash completion and man page only available if binary install is done #}
    {% if 'zsh' in completion %}
      {% set zsh_comp_file = pillar.directories.completions.zsh + '/_rg' %}
rg-zsh-completion:
  file.managed:
    - name:     {{ zsh_comp_file }}
    - source:   https://github.com/BurntSushi/ripgrep/blob/master/complete/_rg
    - makedirs: True
    - skip_verify: True
    - replace:  False
    {% endif %}
  {% endif %}

  {% if grains.cfg_ripgrep.debug.enable %}
ripgrep-version:
  cmd.run:
    - name:     {{ ripgrep_path_name }}{{ ripgrep_bin_name }} --version
  {% endif %}
{% endif %}

