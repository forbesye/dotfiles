#!/bin/bash
set -euo pipefail

# Point iTerm2 at the chezmoi-managed prefs folder so it loads the tracked
# plist (~/.config/iterm2/com.googlecode.iterm2.plist) instead of the default
# ~/Library location. Runs once per machine.
if [ -f "$HOME/.config/iterm2/com.googlecode.iterm2.plist" ]; then
  echo "==> Pointing iTerm2 at ~/.config/iterm2 for its preferences..."
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.config/iterm2"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
fi
