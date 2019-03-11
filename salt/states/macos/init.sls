# Make MacOS finder developer friendly

show-hidden-files:
  cmd.run:
    - name: defaults write com.apple.finder AppleShowAllFiles TRUE

show-hidden-extensions:
  cmd.run:
    - name: defaults write com.apple.finder AppleShowAllExtensions TRUE

