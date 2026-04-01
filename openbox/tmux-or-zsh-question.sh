#!/bin/bash
printf 'Start tmux [Enter] or [z]sh? '
read -r -n 1 choice
echo
case "$choice" in
    z|Z)
        exec zsh
        ;;
    *)
        exec tmux
        ;;
esac
