#!/bin/bash

set -e

if [[ $# -ne 2 ]]; then
    echo 'incorrect number of arguments'
    exit 1
fi

# Read arguments
branch=$1
changelog=$2
slack=

clean_up() {
    changelog="${changelog//\`/}"
    changelog="${changelog//\'/}"
    changelog="${changelog//\"/}"
}

replace_for_master() {
    changelog="${changelog//'%'/'%25'}"
    changelog="${changelog//$'\n'/'%0A'}"
    changelog="${changelog//$'\r'/'%0D'}"
}

slack_output() {
    local IFS=$'\n' # make newlines the only separator
    local temp=
    for j in $(echo "$changelog")
    do
        hash=${j:0:7}
        link="<https://github.com/wakatime/wakatime-cli/commit/$hash|$hash>"
        temp=$temp$(echo "$j" | awk '{printf "<https://github.com/wakatime/wakatime-cli/commit/"$1"|"$1">";$1=""; printf "%s\\n",$0 }')
    done

    slack=$(echo -e "*Changelog*\n$temp")
}

process_for_develop() {
    changelog=$(awk 'f;/## Changelog/{f=1}' <<< "$changelog")
}

process_for_master() {
    changelog=$(awk 'f;/Changelog:/{f=1}' <<< "$changelog")
}

case $branch in
    develop) process_for_develop clean_up ;;
    master) process_for_master clean_up replace_for_master ;;
    *) exit 1 ;;
esac

slack_output

echo "::set-output name=changelog::$changelog"
echo "::set-output name=slack::$slack"
