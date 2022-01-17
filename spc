#!/bin/bash

TAG='v2'
VERSION='0.0.3'
GITHUB='https://github.com'

export RUNNER_TOOL_PATH="/tmp"
export RUNNER_TOOL_CACHE="/tmp"

read -r -d '' HELP << EOM
    SYNOPSIS
    spc [options]
    Note: Options should be wrapped in quotes. For example --tools "phpstan, phpunit"

    DESCRIPTION
    spc is a tool to run setup-php

    OPTIONS
    -p "[PHP Version]", --php-version "[PHP Version]"    Specify PHP version (Required if PHP is not installed)
    -e "[Extensions]", --extensions "[Extensions]"       Specify extensions
    -i "[INI Values]", --ini-values "[INI Values]"       Specify ini values
    -c "[Coverage]", --coverage "[Coverage]"             Specify Coverage driver
    -t "[Tools]", --tools "[Tools]"                      Specify tools
    -f "[Fail Fast]", --fail-fast "[Fail Fast]"          Specify fail-fast flag
    -z "[PHP TS/NTS]", --phpts "[PHPTS/NTS]"             Specify phpts flag
    -u "[Update]", --update "[Update]"                   Specify update flag
    -r "[TAG]", --release "[TAG]"                        Specify release
    -v, --verbose                                        Specify verbose mode
    -V, --version                                        Show version of script
    -h, --help                                           Show help

    EXAMPLES
    spc -p "7.4" -e "intl, xml" -t "cs2pr, phpunit"
    spc --php-version "7.4" --extensions "intl, xml" --tools "phpstan, phpunit"
EOM

upgrade() {
  sudo curl -o /tmp/spc -sL "$GITHUB"/shivammathur/spc/releases/latest/download/spc
  bash /tmp/spc -V
  trap "sudo mv /tmp/spc /usr/local/bin/spc; sudo chmod a+x /usr/local/bin/spc" EXIT
  exit 0
}

err() {
  printf "\033[33;1m%s \033[0m\n" "$*"
}

check_url() {
  curl -o /dev/null -sfIL "$1"
}

while [ $# -gt 0 ] ; do
  case $1 in
    -p | --php-version) php_version="$2" ;;
    -e | --extensions) extensions="$2" ;;
    -i | --ini-values) ini_values="$2" ;;
    -c | --coverage) coverage="$2" ;;
    -t | --tools) tools="$2" ;;
    -r | --release) TAG="$2" ;;
    -f | --fail-fast) fail_fast="$2" ;;
    -z | --phpts) phpts="$2" ;;
    -u | --update) update="$2" ;;
    -v | --verbose) TAG="verbose" ;;
    -V | --version) echo "$VERSION"; exit 0; ;;
    -U | --upgrade) upgrade; exit 0; ;;
    -h | --help) echo "$HELP"; exit 0; ;;
  esac
  shift
done

if [ "$TAG" = "verbose" ]; then
  printf "\n\033[90;1m==> \033[0m\033[37;1mInputs\033[0m\n"
  printf "\033[34;1mrelease: \033[0m\033[33;1m%s\033[0m\n" "$TAG"
  if [ "$php_version" != "" ]; then printf "\033[34;1mphp-version: \033[0m\033[33;1m%s\033[0m\n" "$php_version"; fi
  if [ "$extensions" != "" ]; then printf "\033[34;1mextensions: \033[0m\033[33;1m%s\033[0m\n" "$extensions"; fi
  if [ "$ini_values" != "" ]; then printf "\033[34;1mini-values: \033[0m\033[33;1m%s\033[0m\n" "$ini_values"; fi
  if [ "$coverage" != "" ]; then printf "\033[34;1mcoverage: \033[0m\033[33;1m%s\033[0m\n" "$coverage"; fi
  if [ "$tools" != "" ]; then printf "\033[34;1mtools: \033[0m\033[33;1m%s\033[0m\n" "$tools"; fi
  if [ "$fail_fast" != "" ]; then printf "\033[34;1mfail-fast: \033[0m\033[33;1m%s\033[0m\n" "$fail_fast"; fi
  if [ "$phpts" != "" ]; then printf "\033[34;1mphpts: \033[0m\033[33;1m%s\033[0m\n" "$phpts"; fi
  if [ "$update" != "" ]; then printf "\033[34;1mupdate: \033[0m\033[33;1m%s\033[0m\n" "$update"; fi
fi

for cmd in sudo printf node; do
  if ! command -v "$cmd" >/dev/null; then
    err "$cmd not found in PATH"
    exit 1;
  fi
done

if [ "$php_version" = "" ]; then
  if command -v php >/dev/null;then
    php_version=$(php -v | grep -Eo -m 1 "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1 | cut -d'.' -f 1-2)
  else
    err "Existing PHP not found and version is not specified"
    err "Run \"spc -h\" for help"
    exit 1;
  fi
fi

if ! check_url "$GITHUB"; then
  err "Unable to reach GitHub"
  err "Please check your internet connection"
  exit 1;
fi

if ! check_url "$GITHUB"/shivammathur/setup-php/tree/"$TAG"; then
  err "Release/Tag $TAG not found on setup-php"
  err "Please specify a valid release"
  exit 1;
fi

rm -rf /tmp/setup-php
curl -sL "$GITHUB"/shivammathur/setup-php/archive/"$TAG".tar.gz | tar -xz -C /tmp
mv /tmp/setup-php* /tmp/setup-php

# Patch color for GitLab
if [ ! -z ${GITLAB_CI+x} ] && [ "$GITLAB_CI" = "true" ]; then
  sed -i 's/\[90/\[37/g' /tmp/setup-php/src/scripts/common.sh
fi

env 'runner=self-hosted' \
  env 'php-version='"$php_version" \
  env 'extensions='"$extensions" \
  env 'ini-values='"$ini_values" \
  env 'coverage='"$coverage" \
  env 'tools='"$tools" \
  env 'fail-fast='"$fail_fast" \
  env 'phpts='"$phpts" \
  env 'update='"$update" node /tmp/setup-php/dist/index.js

exit 0;
