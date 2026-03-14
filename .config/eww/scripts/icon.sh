#!/usr/bin/env bash
set -euo pipefail

ICON_NAME="${1:-}"
if [ -z "$ICON_NAME" ]; then
    echo "Usage: $0 <icon-name-or-appid>"
    exit 1
fi

EXTENSIONS=("png" "svg")
ICON_PATHS=(
    "$HOME/.icons"
    "$HOME/.local/share/icons"
    "/usr/share/icons"
    "/usr/share/pixmaps"
)

# Rekursive Suche in allen Icon-Pfaden
find_icon_file() {
    local name="$1"
    for path in "${ICON_PATHS[@]}"; do
        for ext in "${EXTENSIONS[@]}"; do
            file=$(find "$path" -type f -iname "${name}.${ext}" 2>/dev/null | head -n1)
            if [ -n "$file" ]; then
                echo "$file"
                return 0
            fi
        done
    done
    return 1
}

# 1️⃣ Versuche direkt zu finden
if file_path=$(find_icon_file "$ICON_NAME"); then
    echo "$file_path"
    exit 0
fi

# 2️⃣ Suche über .desktop Dateien
DESKTOP_PATHS=(
    "/usr/share/applications"
    "$HOME/.local/share/applications"
)
for path in "${DESKTOP_PATHS[@]}"; do
    for desktop in "$path"/*.desktop; do
        [ -f "$desktop" ] || continue
        icon=$(grep -E '^Icon=' "$desktop" | head -n1 | cut -d'=' -f2)
        # rekursiv in Icon-Pfaden suchen
        if [ -n "$icon" ]; then
            if file_path=$(find_icon_file "$icon"); then
                echo "$file_path"
                exit 0
            fi
        fi
    done
done

# 3️⃣ Letzter Fallback
echo "$ICON_NAME"