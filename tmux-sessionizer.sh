#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(stribog -u -i -r ~/dev -r  ~/.config/nvim -r /mnt/c/Dev -f asset  -f .plugin -f resource -f test -f conf -f logs -f .git -f .next -f .swc -f node_modules -f e2e -f build -f target -f dist  | fzf)

fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
