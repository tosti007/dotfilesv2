#!/usr/bin/env bash
#
# Every directory in ./user/ will be stowed to $HOME and every directory in
# ./system/ will be stowed to /. If there's an executable file named 'install'
# present in a directory, the script will be executed instead.

source ./assets/ask.sh
source ./assets/packages.sh

function stow2() {
  # Execute a script instead of stowing if an installation script is present
  if [[ -x $1/install ]]; then
    command="$1/install"
    if [[ -n "$DRY_RUN" ]]; then
      command="echo \"Execute $command\""
    fi
  else
    command="stow $1 -t $2 -v"
    if [[ -n "$DRY_RUN" ]]; then
      command+=" --no 2>&1 \
        | grep -v 'WARNING: in simulation mode so not modifying filesystem.'"
    fi
  fi

  if [[ -z "$DRY_RUN" && $2 == '/' ]]; then
    command="sudo $command"
  fi

  if [[ -n "$NO_ASK" ]] || ask "Install configuration for $1?" Y; then
    eval "$command"
  fi
}

function install() {
  # Install a list of packages if not yet installed
  
  # Remove any comments and replace newlines with spaces
  pkglist=$(packages-parse $1)
  
  if [[ -n "$DRY_RUN" ]]; then
    command="echo -e 'Install:\\n\\t$pkglist'"
  else
    command="packages-install $pkglist"
  fi

  if [[ -n "$NO_ASK" ]] || ask "Install packages for ${1%.pkgs}?" Y; then
    eval "$command"
  fi
}

function installdir() {
  cd "$1"
  for package in *.pkgs; do
    if [[ -f "$package" ]]; then
      install "$package"
    fi
  done
  cd ..
}

function stowdir() {
  # Loop trough all files and stow or install it if applicable
  cd "$1"
  for package in *; do
    if [[ -d "$package" ]]; then
      stow2 "$package" "$2"
    fi
  done
  cd ..
}

cd "$(dirname "$0")"

git submodule init >/dev/null
git submodule update >/dev/null

if ask 'Dry run?' Y; then
  DRY_RUN=1
else
  set -e
  set -o pipefail
fi

if [[ "$#" -gt 0 ]]; then
  NO_ASK=1
  # Handle all asked configs
  for package in "$@"; do
    if [ -d "$package" ]; then
      packagename=`basename $package`
      packagedir=`dirname $package`
      packageout="$HOME"
      if [[ "$packagedir" == 'system' ]]; then
        packageout='/'
      fi
      cd "$packagedir"
      stow2 "$packagename" "$packageout"
      cd ..
    fi
  done

else

  if ask 'Install everything?' N; then
    NO_ASK=1
  fi

  # Handle all packages we can find
  if [[ -n "$NO_ASK" ]] || ask "Install packages?" N; then
    if [[ -z "$DRY_RUN" ]]; then
      echo 'Installing packages...'
    else
      echo 'Dry run packages...'
    fi
    installdir 'packages'
  fi

  # Handle all configs we can find
  if [[ -z "$DRY_RUN" ]]; then
    echo 'Installing configuration...'
  else
    echo 'Dry run configuration...'
  fi
  stowdir 'user' "$HOME"
  if [[ -z "$DRY_RUN" ]]; then
    echo ''
    echo 'Installing systemm wide configuration...'
    echo 'NOTE: Misconfiguration could mess up your system'
  fi
  stowdir 'system' '/'

fi

exit 0
