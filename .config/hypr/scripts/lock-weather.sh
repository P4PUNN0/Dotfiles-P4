#!/usr/bin/env bash
# ~/.config/hypr/scripts/lock-weather.sh
# Reads weather information from cache or defaults for hyprlock

CACHE_FILE="$HOME/.cache/43pr/weather-panel.json"
mode="${1:-text}"

python3 - "$CACHE_FILE" "$mode" << 'EOF'
import sys, json, os

cache_path = sys.argv[1]
mode = sys.argv[2] if len(sys.argv) > 2 else "text"

# WMO Weather interpretation codes (WW)
code_map = {
    0: ("Despejado", "󰖙", "󰖔"),
    1: ("Mayormente despejado", "󰖐", "󰼱"), 
    2: ("Parcialmente nublado", "󰖐", "󰼱"), 
    3: ("Nublado", "󰖐", "󰖐"),
    45: ("Niebla", "󰖑", "󰖑"), 48: ("Niebla helada", "󰖑", "󰖑"),
    51: ("Llovizna ligera", "󰖗", "󰖗"), 53: ("Llovizna", "󰖗", "󰖗"), 55: ("Llovizna densa", "󰖗", "󰖗"),
    61: ("Lluvia débil", "󰖖", "󰖖"), 63: ("Lluvia moderada", "󰖖", "󰖖"), 65: ("Lluvia fuerte", "󰖖", "󰖖"),
    71: ("Nieve ligera", "󰼶", "󰼶"), 73: ("Nieve moderada", "󰼶", "󰼶"), 75: ("Nieve fuerte", "󰼶", "󰼶"),
    80: ("Chubascos", "󰖖", "󰖖"), 81: ("Chubascos", "󰖖", "󰖖"), 82: ("Chubascos fuertes", "󰖖", "󰖖"),
    95: ("Tormenta eléctrica", "󰙾", "󰙾"), 96: ("Granizo", "󰙾", "󰙾"), 99: ("Tormenta fuerte", "󰙾", "󰙾")
}

location = "Miguel Hidalgo"
desc = "Llovizna ligera"
icon = "󰖗"
humidity = 86
temp = 12

if os.path.exists(cache_path):
    try:
        with open(cache_path, "r") as f:
            data = json.load(f)
            code = data.get("code", 51)
            is_day = data.get("isDay", True)
            entry = code_map.get(code, ("Lluvia ligera", "󰖗", "󰖗"))
            desc = entry[0]
            icon = entry[1] if is_day else entry[2]
            humidity = int(data.get("humidity", 86))
            temp = round(float(data.get("tempC", 12)))
            raw_loc = data.get("loc") or data.get("city")
            if raw_loc:
                location = raw_loc.strip()
    except Exception:
        pass

if len(location) > 19:
    location = location[:18] + "…"

if mode == "icon":
    print(icon)
elif mode == "desc":
    print(desc)
elif mode == "temp":
    print(f"{temp}°C")
elif mode == "location":
    print(location)
elif mode == "humidity":
    print(f"{humidity}%")
elif mode == "text":
    # Formatted for Hyprlock with location, degrees, weather condition and humidity
    print(f"<b>{location}</b>\n<span foreground=\"#00e5ff\"><b>{temp}°C</b></span> <span foreground=\"#c9c5c7\">· {desc}</span>\n<span size=\"small\" foreground=\"#8b909a\">󰖖 Humedad: {humidity}%</span>")
else:
    print(f"{icon}  {location} · {temp}°C ({humidity}%)")
EOF
