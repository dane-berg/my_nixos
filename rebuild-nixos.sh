#!/usr/bin/env bash
# Forked from https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5
# A rebuild script that commits on a successful build
set -eo pipefail

log_file=nixos-switch.log
host_name=$(hostname)

# Parse optional arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --flake)
      shift
      if [[ -n "$1" ]]; then
        host_name="$1"
        shift
      else
        echo "Error: --flake requires a value."
        exit 1
      fi
      ;;
    --) # end of options
      shift
      break
      ;;
    -*) # unknown option
      echo "Unknown option: $1"
      exit 1
      ;;
    *) # positional argument (file)
      break
      ;;
  esac
done

# assert host_name is nonempty
if ! [ -n "$host_name" ]; then
  echo "Empty hostname"
  exit 1
fi

# cd to your config dir
pushd /etc/nixos/

# Check if at least one file is provided as an argument
if ! [ $# -eq 0 ]; then
  # open each file in the default editor
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
git add .
git diff -U0 HEAD

echo "NixOS Rebuilding..."

spinner()
{
  local pid=$!
  local delay=0.75
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# Rebuild & log traceback while displaying a spinner
sudo nixos-rebuild switch --flake /etc/nixos#$host_name &> "$log_file" &
spinner

# Output simplified errors
export GREP_COLORS='ms=01;31' # display errors in red
error_message=$(cat "$log_file" | grep -A 4 --color='always' -i "error:" || (( $? == 1)))
if [ -n "$error_message" ]; then
  echo "nixos-rebuild switch --flake /etc/nixos#$host_name failed with message:"
  echo "$error_message"
  exit 1
fi

# Output warnings if there are no errors
export GREP_COLORS='ms=01;34' # display warnings in blue
warning_message=$(cat "$log_file" | grep --color='always' -i "evaluation warning" || (( $? == 1)))
echo "$warning_message"
tail -n 1 "$log_file"
echo "" # newline

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes with the generation metadata
git commit -aqm "$host_name $current"

# Allow the user to write a custom commit message
git commit --amend

# Back to where you were
popd

# Notify all OK!
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
