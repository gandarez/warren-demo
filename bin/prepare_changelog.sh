#!/bin/bash

set -e

if [[ $# -ne 2 ]]; then
    echo 'incorrect number of arguments'
    exit 1
fi

# Read arguments
branch=$1
changelog=$2

clean_up() {
    changelog="${changelog//\`/}"
    changelog="${changelog//\'/}"
    changelog="${changelog//\"/}"
    changelog="${changelog//'%'/'%25'}"
    changelog="${changelog//$'\n'/'%0A'}"
    changelog="${changelog//$'\r'/'%0D'}"
}

process_for_develop() {
    changelog=$(awk 'f;/## Changelog/{f=1}' <<< "$changelog")
    clean_up
}

process_for_master() {
    changelog=$(awk 'f;/Changelog:/{f=1}' <<< "$changelog")
    clean_up
}

case $branch in
    develop) process_for_develop ;;
    mastter) process_for_master ;;
    *) exit 1 ;;
esac

echo "::set-output name=changelog::$changelog"
