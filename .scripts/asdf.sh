#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "$0")/utils.sh"

bold "$(blue "Let's use ASDF!\n\n")"

if [ ! -d "${HOME}/.asdf" ]; then
  blue "ASDF not present. Cloning it on ${HOME}/.asdf ...\n"
  git clone --quiet https://github.com/asdf-vm/asdf.git "${HOME}/.asdf"
  if [ -f "${HOME}/.bash_profile" ]; then
    blue "Adding ASDF to ${HOME}/.bash_profile ...\n"
    echo "source ${HOME}/.asdf/asdf.sh" >> "${HOME}/.bash_profile"
  elif [ -f "${HOME}/.zshrc" ]; then
    blue "Adding ASDF to ${HOME}/.zshrc ...\n"
    echo "source ${HOME}/.asdf/asdf.sh" >> "${HOME}/.zshrc"
  else
    blue "Add this line to your shell profile:\n"
    bold "source \${HOME}/.asdf/asdf.sh\n"
  fi
fi

if ! command -v asdf &> /dev/null; then
  blue "asdf command not found, evaluating ${HOME}/.asdf/asdf.sh ...\n"
  # shellcheck disable=SC1091
  source "${HOME}/.asdf/asdf.sh"
fi

# shellcheck disable=SC2013
for i in $(cut -d' ' -f1 .tool-versions); do
  blue "Adding ${i} plugin to ASDF...\n"
  asdf plugin add "${i}" &> /dev/null
done

blue "Installing plugins to be used here...\n"
asdf install &> /dev/null

green "\nASDF installation complete!\n"
