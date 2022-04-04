#!/bin/bash

kebab-case() {
  echo "${1}" \
    | sed 's/\([^A-Z]\)\([A-Z]\)/\1-\2/g' \
    | sed 's/\([A-Z]\)\([A-Z]\)\([^A-Z]\)/\1-\2\3/g' \
    | tr '[:upper:]' '[:lower:]'
}

red() {
  echo -en "$(tput setaf 1)${1}$(tput sgr0)"
}

green() {
  echo -en "$(tput setaf 2)${1}$(tput sgr0)"
}

blue() {
  echo -en "$(tput setaf 4)${1}$(tput sgr0)"
}

bold() {
  echo -en "$(tput bold)${1}$(tput sgr0)"
}
