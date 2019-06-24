# Make MacOS finder developer friendly

{% set commands = grains.cfg_macos.commands %}

{% if commands and 'show-all-files' in commands %}
show-all-files:
  cmd.run:
    - name: defaults write com.apple.finder AppleShowAllFiles TRUE
{% endif %}

{% if commands and 'show-all-extensions' in commands %}
show-all-extensions:
  cmd.run:
    - name: defaults write com.apple.finder AppleShowAllExtensions TRUE
{% endif %}
