#!/usr/bin/env bash
# ~/.config/hypr/scripts/lock-fetch.sh
# System information display for hyprlock in exact Caelestia fetch style

python3 - << 'EOF'
import os

user = os.environ.get("USER", "rodrigo")
wm = "Hyprland"

# Uptime
try:
    with open("/proc/uptime", "r") as f:
        up_s = float(f.readline().split()[0])
        h = int(up_s // 3600)
        m = int((up_s % 3600) // 60)
        up_str = f"{h}h, {m}m" if h > 0 else f"{m} mins"
except Exception:
    up_str = "13h, 25m"

# Battery / OS
batt_str = "(=) 100%"
bat_cap_path = "/sys/class/power_supply/BAT0/capacity"
bat_stat_path = "/sys/class/power_supply/BAT0/status"
if os.path.exists(bat_cap_path):
    try:
        with open(bat_cap_path) as f:
            cap = f.read().strip()
        with open(bat_stat_path) as f:
            stat = f.read().strip()
        sym = "(+)" if stat == "Charging" else "(=)" if stat == "Full" else "(-)"
        batt_str = f"{sym} {cap}%"
    except Exception:
        batt_str = "(=) 100%"
else:
    batt_str = "(=) 100%"

gray = "#8b909a"
white = "#e5e1e3"

lines = [
    f"<span foreground=\"{gray}\">WM  :</span> <span foreground=\"{white}\"><b>{wm}</b></span>",
    f"<span foreground=\"{gray}\">USER:</span> <span foreground=\"{white}\"><b>{user}</b></span>",
    f"<span foreground=\"{gray}\">UP  :</span> <span foreground=\"{white}\"><b>{up_str}</b></span>",
    f"<span foreground=\"{gray}\">BATT:</span> <span foreground=\"{white}\"><b>{batt_str}</b></span>",
]
print("\n".join(lines))
EOF
