#!/bin/bash
blacklisted () {
    case $1 in
        eorg_*) return 1 ;;
        *) return 0 ;;
    esac
}

env_save () { # Assume "$STORAGE/#1.sh" is empty
    local VAR
    for VAR in $(compgen -A export); do
        blacklisted $VAR || \
            echo "export $VAR='${!VAR}'" >> $1
    done
}

env_restore () {
    local VAR
    for VAR in $(compgen -A export); do
        blacklisted $VAR || \
            unset $VAR
    done
    source $1
}