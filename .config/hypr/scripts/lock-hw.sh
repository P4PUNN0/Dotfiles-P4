#!/usr/bin/env bash
# ~/.config/hypr/scripts/lock-hw.sh
# Hardware dials for hyprlock: cpu, temp, ram, disk

target="${1:-cpu}"

python3 - "$target" << 'EOF'
import sys, os, shutil

target = sys.argv[1] if len(sys.argv) > 1 else "cpu"

if target == "cpu":
    try:
        with open("/proc/loadavg") as f:
            load = float(f.read().split()[0])
            cpu_pct = min(100, max(5, int(load * 25)))
    except Exception:
        cpu_pct = 15
    print(f"◜ 󰍛 ◝\n<span size=\"small\" foreground=\"#00e5ff\"><b>{cpu_pct}%</b></span>")

elif target == "temp":
    temp = 38
    try:
        for tpath in ["/sys/class/thermal/thermal_zone0/temp", "/sys/class/hwmon/hwmon0/temp1_input"]:
            if os.path.exists(tpath):
                with open(tpath) as f:
                    temp = int(int(f.read().strip()) / 1000)
                break
    except Exception:
        pass
    print(f"◜ 󰔏 ◝\n<span size=\"small\" foreground=\"#ff7043\"><b>{temp}°C</b></span>")

elif target == "ram":
    try:
        with open("/proc/meminfo") as f:
            lines = dict(line.split(":", 1) for line in f if ":" in line)
        total_m = float(lines["MemTotal"].split()[0])
        avail_m = float(lines["MemAvailable"].split()[0])
        ram_pct = int(((total_m - avail_m) / total_m) * 100)
    except Exception:
        ram_pct = 35
    print(f"◜ 󰘚 ◝\n<span size=\"small\" foreground=\"#b388ff\"><b>{ram_pct}%</b></span>")

elif target == "disk":
    try:
        t, u, f = shutil.disk_usage("/")
        disk_pct = int((u / t) * 100)
    except Exception:
        disk_pct = 20
    print(f"◜ 󰋊 ◝\n<span size=\"small\" foreground=\"#ff4081\"><b>{disk_pct}%</b></span>")
EOF
