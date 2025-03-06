#!/usr/bin/env bash
# Forked from https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5
# A rebuild script that commits on a successful build
set -e

# cd to your config dir
pushd /etc/nixos/

# Check if at least one file is provided as an argument
if [ $# -eq 0 ]; then
  # Default to editing main config
  $EDITOR configuration.nix
else
  for file in "$@"; do
  	  if [ -f "$file" ]; then
	    echo "Editing file: $file"
        $EDITOR "$file"
	  else
	    echo "Skipping non-existent or invalid file: $file"
	  fi
  done
fi

# Early return if no changes were detected (thanks @singiamtel!)
if git diff --quiet HEAD; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat your nix files
alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

alejandra modules/ &>/dev/null \
  || ( alejandra modules/ ; echo "formatting failed!" && exit 1)

# Adds and shows your changes
git diff -U0 HEAD

echo "NixOS Rebuilding..."

# Rebuild, output simplified errors, log trackebacks
sudo nixos-rebuild switch --flake /etc/nixos#default &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes with the generation metadata
git commit -am "$current"

# Allow the user to write a custom commit message
git commit --amend

# Back to where you were
popd

# Notify all OK!
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
