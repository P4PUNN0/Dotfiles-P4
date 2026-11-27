#!/usr/bin/env bash
# ~/.config/hypr/scripts/lock-media.sh
# Spotify MPRIS media integration for hyprlock

export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
cmd="${1:-text}"

python3 - "$cmd" << 'EOF'
import sys, subprocess, os, urllib.request, shutil
from PIL import Image

cmd = sys.argv[1] if len(sys.argv) > 1 else "text"
cover_path = "/tmp/hyprlock-cover.png"
cache_url_path = "/tmp/hyprlock-media-arturl.txt"
fallback_cover = "/home/rodrigo/.config/hypr/assets/spotify-fallback.png"
if not os.path.exists(fallback_cover):
    fallback_cover = "/home/rodrigo/dotfiles/.config/hypr/assets/spotify-fallback.png"

def get_player_info():
    fmt = "{{playerName}}\x1f{{status}}\x1f{{title}}\x1f{{artist}}\x1f{{mpris:artUrl}}"
    # 1. Try Spotify explicitly first
    try:
        raw = subprocess.check_output(
            ["playerctl", "-p", "spotify", "metadata", "--format", fmt],
            stderr=subprocess.DEVNULL, text=True
        ).strip()
        parts = raw.split("\x1f")
        if len(parts) >= 4:
            return parts
    except Exception:
        pass

    # 2. Try any active MPRIS player
    try:
        raw = subprocess.check_output(
            ["playerctl", "-a", "metadata", "--format", fmt],
            stderr=subprocess.DEVNULL, text=True
        )
        lines = [l.split("\x1f") for l in raw.strip().split("\n") if l.strip()]
        for row in lines:
            if len(row) >= 4 and "spotify" in row[0].lower():
                return row
        for row in lines:
            if len(row) >= 4 and row[1] == "Playing":
                return row
        if lines and len(lines[0]) >= 4:
            return lines[0]
    except Exception:
        pass
    return None

info = get_player_info()

def sync_cover(art_url):
    last_url = ""
    if os.path.exists(cache_url_path):
        try:
            with open(cache_url_path, "r") as f:
                last_url = f.read().strip()
        except Exception:
            pass

    if art_url:
        if art_url == last_url and os.path.exists(cover_path):
            return
        
        # Download or copy new art
        try:
            temp_raw = "/tmp/hyprlock-art-download"
            temp_out = "/tmp/hyprlock-cover-temp.png"
            if art_url.startswith("file://"):
                local_path = art_url.replace("file://", "")
                if os.path.exists(local_path):
                    img = Image.open(local_path).convert("RGBA")
                    img = img.resize((256, 256), Image.Resampling.LANCZOS)
                    img.save(temp_out, "PNG")
                    os.replace(temp_out, cover_path)
                    with open(cache_url_path, "w") as f:
                        f.write(art_url)
                    return
            elif art_url.startswith("http://") or art_url.startswith("https://"):
                req = urllib.request.Request(
                    art_url, 
                    headers={'User-Agent': 'Mozilla/5.0'}
                )
                with urllib.request.urlopen(req, timeout=3) as resp:
                    with open(temp_raw, 'wb') as f_raw:
                        f_raw.write(resp.read())
                img = Image.open(temp_raw).convert("RGBA")
                img = img.resize((256, 256), Image.Resampling.LANCZOS)
                img.save(temp_out, "PNG")
                os.replace(temp_out, cover_path)
                with open(cache_url_path, "w") as f:
                    f.write(art_url)
                return
        except Exception:
            pass

    # Fallback when no art or inactive
    if last_url != "FALLBACK" or not os.path.exists(cover_path):
        if os.path.exists(fallback_cover):
            try:
                shutil.copyfile(fallback_cover, cover_path)
                with open(cache_url_path, "w") as f:
                    f.write("FALLBACK")
            except Exception:
                pass

art_url = info[4].strip() if (info and len(info) >= 5) else ""
sync_cover(art_url)

if cmd == "header":
    if info and "spotify" in info[0].lower():
        print("󰓇  Spotify")
    elif info:
        print(f"󰝚  {info[0].capitalize()}")
    else:
        print("󰓇  Spotify")

elif cmd == "play-icon":
    if info and info[1] == "Playing":
        print("󰏤")
    else:
        print("󰐊")

elif cmd == "text":
    if info:
        player, status, title, artist = info[0], info[1], info[2], info[3]
        title_str = title if len(title) <= 22 else title[:21] + "…"
        artist_str = artist if len(artist) <= 24 else artist[:23] + "…"
        prefix = "󰏤 " if status != "Playing" else ""
        print(f"<b>{title_str}</b>\n<span size=\"small\" foreground=\"#8b909a\">{prefix}{artist_str}</span>")
    else:
        print("<b>No hay música</b>\n<span size=\"small\" foreground=\"#8b909a\">Spotify en pausa</span>")

elif cmd == "cover":
    pass
EOF
