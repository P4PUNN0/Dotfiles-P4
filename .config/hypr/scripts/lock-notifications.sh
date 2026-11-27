#!/usr/bin/env bash
# ~/.config/hypr/scripts/lock-notifications.sh
# Real notification sync from quickshell notification history for hyprlock

mode="${1:-card}"
cache_file="$HOME/.cache/43pr/notifications.json"

python3 - "$mode" "$cache_file" << 'EOF'
import sys, json, os

mode = sys.argv[1] if len(sys.argv) > 1 else "card"
cache_path = sys.argv[2] if len(sys.argv) > 2 else ""

notifs = []
if os.path.exists(cache_path):
    try:
        with open(cache_path, "r") as f:
            raw = json.load(f)
            if isinstance(raw, list):
                notifs = raw
    except Exception:
        pass

count = len(notifs)

if mode == "header":
    if count == 0:
        print("󰂚  notifications")
    elif count == 1:
        print("󰂚  1 notification")
    else:
        print(f"󰂚  {count} notifications")

elif mode == "count":
    print(str(count))

else:
    # "card" or full view
    if count == 0:
        print(
            "<span size=\"26000\" foreground=\"#6f737d\">󰂛</span>\n\n"
            "<span size=\"medium\" foreground=\"#c9c5c7\"><b>Sin notificaciones</b></span>\n"
            "<span size=\"small\" foreground=\"#8b909a\">Todo al día</span>"
        )
    else:
        icon_map = {
            "spotify": ("󰓇", "#1db954"),
            "discord": ("󰙯", "#5865f2"),
            "telegram": ("󰔁", "#2aabee"),
            "firefox": ("󰈹", "#ff7139"),
            "brave": ("󰈹", "#fb542b"),
            "chrome": ("󰈹", "#4285f4"),
            "kitty": ("", "#ff5555"),
        }
        
        out = []
        for n in list(reversed(notifs))[:3]:
            app = str(n.get("appName", "Notificación")).lower()
            title = str(n.get("summary", "") or n.get("appName", "Alerta")).strip()
            body = str(n.get("body", "")).strip() or title

            icon, color = ("󰂚", "#00e5ff")
            for k, (ic, col) in icon_map.items():
                if k in app or k in title.lower():
                    icon, color = ic, col
                    break

            title_clean = (n.get("appName") or "Notificación")[:18]
            desc_clean = (n.get("summary") or body).replace("\n", " ")
            if len(desc_clean) > 28:
                desc_clean = desc_clean[:27] + "…"

            out.append(f"<span foreground=\"{color}\">{icon}</span>  <b>{title_clean}</b>\n<span size=\"small\" foreground=\"#8b909a\">{desc_clean}</span>")

        print("\n\n".join(out))
EOF
