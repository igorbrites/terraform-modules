#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "$0")/utils.sh"

bold "$(blue "Let's create a new module!\n\n")"

blue "Which provider will you use: "
read -r provider

blue "What is the name of the module: "
read -r module

provider=$(kebab-case "${provider}")
module=$(kebab-case "${module}")
path="modules/${provider}/${module}"

[ ! -d "${path}" ] || (red "There is already a module at ${path}. Exiting...\n"; exit 1)

blue "The path will be "; bold "$(blue "${path}")"; blue ". Accept? [Y/n] "
read -r answer

[ "$(echo "${answer:=y}" | tr '[:upper:]' '[:lower:]')" = "y" ] || (red "Cancelled by user\n"; exit 1)

mkdir -p "${path}"
cp .template/* "${path}"

package=$(jq --arg name "terraform-${provider}-${module//\//-}" '.name = $name' "${path}/package.json")
echo "${package}" > "${path}/package.json"

readme=$(sed "s~{{module}}/{{provider}}~${module}/${provider}~g" "${path}/README.md")
echo "${readme}" "${path}/README.md"

green "Module ${module} created successfully. Happy Terraforming!\n"
