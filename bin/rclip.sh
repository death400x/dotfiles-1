#!/usr/bin/env bash
# Remote clipboard insertion via SSH
# By Henrik Lissner <henrik@lissner.net>
#
# A simple script for sending data to another computer's clipboard via SSH. Acts as
# a universal clipboard. This script must be available on the remote. Pipe through gpg
# if you want the contents encrypted.
#
# It helps if your ssh connection is pubkey authenticated and password-less.
#
# If the destination (or host) is a mac, use pbcopy and pbpaste instead.
#
# Workflow:
#   host  $ echo "Hello world!" | rclip.sh guest
#   guest $ rclip.sh
#         Hello world!
#     OR
#   host  $ echo "Hello world!" | gpg -e | rclip.sh guest
#   guest $ rclip.sh | gpg -d
#         Hello world!

pb=/tmp/rcopy-pb
bin="${0##*/}"

copy() { [[ $OSTYPE == darwin* ]] && pbpaste; }

target="$1"
flags=
while getopts p:i:l: opt; do
    case $opt in
        p) flags+=" -p $OPTARG" ;;
        i) flags+=" -i $OPTARG" ;;
        l) flags+=" -l $OPTARG" ;;
        *) >&2 echo "Invalid option $OPTARG"
           exit 1
           ;;
    esac
done
shift $((OPTIND-1))

if [[ -t 1 || $force_output ]]; then
    if [[ $target ]]; then
        ssh $flags -qt "$target" "$bin"
    elif [[ $OSTYPE == darwin* ]]; then
        pbpaste
    elif [[ -f $pb ]]; then
        cat "$pb"
    else
        exit 1
    fi
elif [[ $target ]]; then
    ssh $flags -q "$target" "$bin"
else
    tee "$pb" | copy
fi

# vim:set ft=sh: