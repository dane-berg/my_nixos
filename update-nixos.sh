#!/usr/bin/env bash
# An update script that commits on a successful build
set -e

# cd to your config dir
pushd /etc/nixos/

# Early return if changes were detected
if ! [ git diff --quiet HEAD ]; then
    echo "Changes detected, exiting."
    popd
    exit 0
fi

echo "Updating NixOS flake..."

# do update
nix flake update &>nixos-update.log || (cat nixos-update.log | grep --color error && exit 1)

# Early return if no changes were detected
if git diff --quiet HEAD; then
    echo "No updates detected, exiting."
    popd
    exit 0
fi

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes with the generation metadata
git commit -am "$current"

# Allow the user to write a custom commit message
git commit --amend

# Back to where you were
popd

# Notify all OK!
notify-send -e "NixOS Updated OK!" --icon=software-update-available
