#!/usr/bin/env bash
# An update script that commits on a successful build
set -e

log_file=nixos-update.log
host_name=$(hostname)

# cd to your config dir
pushd /etc/nixos/

# Early return if changes were detected
if ! git diff --quiet HEAD; then
    echo "Changes detected, exiting."
    popd
    exit 0
fi

echo "Updating NixOS flake..."

spinner()
{
  local pid=$!
  local delay=0.75
  local spinstr='|/-\'
  while [ "$ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c] " "$spinstr"
    local spinstr=$temp${spinstr%"temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# do update
nix flake update &> "$log_file" || (cat "$log_file" | grep --color error && exit 1) &
spinner

# Early return if no changes were detected
if git diff --quiet HEAD; then
    echo "No updates detected, exiting."
    popd
    exit 0
fi

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep True || (( $? == 1 )))

# Commit all changes with the generation metadata
git commit -aqm "$host_name $current"

# Allow the user to write a custom commit message
git commit --amend

# Back to where you were
popd

# Notify all OK!
notify-send -e "NixOS Updated OK!" --icon=software-update-available
