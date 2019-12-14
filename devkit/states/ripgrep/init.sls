# Install ripgrep

{% set installs = grains.cfg_ripgrep.installs %}
{% set ripgrep_pkg_name = 'ripgrep' %}
{% set ripgrep_bin_name = 'rg' %}

{% if installs and 'ripgrep' in installs %}

ripgrep:
  {% if grains.os_family in ('Debian', 'RedHat', 'Suse') %}
  pkgrepo.managed:
    {% if grains.os_family == 'Debian' %}
    - ppa:      x4121/ripgrep
    {% elif grains.os == 'CentOS' %}
    - humanname: Copr repo for ripgrep owned by carlwgeorge
    - baseurl: https://copr-be.cloud.fedoraproject.org/results/carlwgeorge/ripgrep/epel-7-{{ grains.cpuarch }}/
    - type: rpm-md
    - skip_if_unavailable: True
    - gpgcheck: 1
    - gpgkey: https://copr-be.cloud.fedoraproject.org/results/carlwgeorge/ripgrep/pubkey.gpg
    - repo_gpgcheck: 0
    - enabled: 1
    - enabled_metadata: 1
    {% elif grains.os_family == 'Suse' %}
    - humanname: all the small tools for the shell (openSUSE_Leap_15.0)
    - baseurl: http://download.opensuse.org/repositories/utilities/openSUSE_Leap_15.0/
    - type: rpm-md
    - gpgcheck: 1
    - gpgkey: http://download.opensuse.org/repositories/utilities/openSUSE_Leap_15.0/repodata/repomd.xml.key
    - enabled: 1
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

  {% if grains.cfg_ripgrep.debug.enable %}
ripgrep-version:
  cmd.run:
    - name:     {{ ripgrep_bin_name }} --version
  {% endif %}
{% endif %}

