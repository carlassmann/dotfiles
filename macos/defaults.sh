#!/usr/bin/env bash

set -euo pipefail

# keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write com.apple.HIToolbox AppleFnUsageType -int 2

# appearance
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 64
defaults write com.apple.dock expose-group-apps -bool true

# window management is aerospace's job
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false

# finder
defaults write com.apple.finder FXPreferredViewStyle -string icnv

# screenshots
defaults write com.apple.screencapture location -string "$HOME/Downloads"

# hyperkey: caps lock -> hyper (ctrl+alt+cmd+shift), quick tap -> esc
defaults write com.knollsoft.Hyperkey capsLockRemapped -int 2
defaults write com.knollsoft.Hyperkey keyRemap -int 1
defaults write com.knollsoft.Hyperkey hyperFlags -int 1966080
defaults write com.knollsoft.Hyperkey executeQuickHyperKey -int 1
defaults write com.knollsoft.Hyperkey quickHyperKeycode -int 53
defaults write com.knollsoft.Hyperkey launchOnLogin -int 1
defaults write com.knollsoft.Hyperkey hideMenuBarIcon -int 1

killall Dock Finder SystemUIServer 2>/dev/null || true
echo "✓ macOS defaults applied (log out for keyboard changes)"
