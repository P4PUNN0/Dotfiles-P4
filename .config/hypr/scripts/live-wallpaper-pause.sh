#!/usr/bin/env bash
# Pause mpvpaper (SIGSTOP) while any visible workspace has open windows.
sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

update() {
    local mons wss pause
    mons=$(hyprctl -j monitors 2>/dev/null) || return
    wss=$(hyprctl -j workspaces 2>/dev/null) || return
    [[ -z "$mons" || -z "$wss" ]] && return

    pause=$(jq -n \
        --argjson mons "$mons" \
        --argjson wss  "$wss" '
        [$mons[].activeWorkspace.id] as $act
        | any($wss[]; (.windows > 0) and ([.id] | inside($act)))' 2>/dev/null)
    if [[ "$pause" == true ]]; then
        pkill -STOP -x mpvpaper 2>/dev/null
    else
        pkill -CONT -x mpvpaper 2>/dev/null
    fi
}

update
socat -U - "UNIX-CONNECT:$sock" | while read -r line; do
    case "${line%%>>*}" in
        openwindow|closewindow|movewindow|workspacev2|focusedmonv2|fullscreen|activewindow|activewindowv2|monitoradded|monitorremoved)
            update ;;
    esac
done
