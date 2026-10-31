#!/usr/bin/env bash
# Verlinkt dieses Repository in $HOME bzw. $XDG_CONFIG_HOME.
#
#   ./install.sh              # verlinken (vorhandene Dateien werden gesichert)
#   ./install.sh --dry-run    # nur anzeigen, was passieren würde
#   ./install.sh --no-backup  # nichts sichern, vorhandene Ziele überspringen
#
# Jeder Eintrag in .config/ wird nach ~/.config/<name> verlinkt, jede
# Dot-Datei im Wurzelverzeichnis nach ~/<name>. Bestehende echte Dateien und
# Verzeichnisse wandern vorher in ~/.dotfiles-backup-<zeitstempel>/.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
DO_BACKUP=1
ERRORS=0

# Wird nicht verlinkt: Repo-Verwaltung, Laufzeitdaten, Skripte ohne Punkt.
SKIP_TOP=(.git .gitignore .crush install.sh README.md LICENSE update-packages)

usage() {
    sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run) DRY_RUN=1 ;;
        --no-backup)  DO_BACKUP=0 ;;
        -h|--help)    usage; exit 0 ;;
        *)            printf 'Unbekannte Option: %s\n\n' "$arg" >&2; usage >&2; exit 2 ;;
    esac
done

skipped() {
    local name=$1 entry
    for entry in "${SKIP_TOP[@]}"; do
        [ "$name" = "$entry" ] && return 0
    done
    return 1
}

backup() {
    local dst=$1 rel
    rel="${dst#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname -- "$rel")"
    if [ "$DRY_RUN" -eq 1 ]; then
        printf 'backup  %s\n' "$dst"
    else
        mv -- "$dst" "$BACKUP_DIR/$rel"
        printf 'backup  %s -> %s\n' "$dst" "$BACKUP_DIR/$rel"
    fi
}

link() {
    local src=$1 dst=$2

    if [ -L "$dst" ]; then
        if [ "$(readlink -- "$dst")" = "$src" ]; then
            printf 'ok      %s\n' "$dst"
            return
        fi
        # alte Verlinkung (z.B. auf einen früheren Klon) wird ersetzt
    elif [ -e "$dst" ]; then
        if [ "$DO_BACKUP" -eq 1 ]; then
            backup "$dst"
        else
            printf 'fehler  %s existiert und --no-backup ist gesetzt\n' "$dst" >&2
            ERRORS=$((ERRORS + 1))
            return
        fi
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        printf 'link    %s -> %s\n' "$dst" "$src"
    else
        mkdir -p "$(dirname -- "$dst")"
        ln -sfn -- "$src" "$dst"
        printf 'link    %s -> %s\n' "$dst" "$src"
    fi
}

# Aufräumen: tote Symlinks, die noch in dieses Repo zeigen (z.B. nach dem
# Entfernen eines nicht mehr genutzten Tool-Configs)
prune_dangling() {
    local link target
    for link in "$HOME"/.[!.]* "$HOME/.config"/* "$HOME/.config"/.[!.]*; do
        [ -L "$link" ] || continue
        [ -e "$link" ] && continue
        target=$(readlink -- "$link")
        case "$target" in
            "$REPO_DIR"/*|"$REPO_DIR") ;;
            *) continue ;;
        esac
        if [ "$DRY_RUN" -eq 1 ]; then
            printf 'prune   %s (zeigt ins Leere)\n' "$link"
        else
            rm -- "$link"
            printf 'prune   %s (zeigt ins Leere)\n' "$link"
        fi
    done
}

[ -d "$REPO_DIR/.config" ] || { printf 'Kein .config/ in %s gefunden\n' "$REPO_DIR" >&2; exit 1; }

# Dot-Dateien im Wurzelverzeichnis (~/.bashrc, ~/.rc, ~/.zshrc, ...)
for src in "$REPO_DIR"/.[!.]*; do
    name=$(basename -- "$src")
    skipped "$name" && continue
    [ "$name" = .config ] && continue
    link "$src" "$HOME/$name"
done

# Jeder Eintrag aus .config/ (~/.config/mango, ~/.config/AGENTS.md, ...)
for src in "$REPO_DIR/.config"/* "$REPO_DIR/.config"/.[!.]*; do
    [ -e "$src" ] || continue
    link "$src" "$CONFIG_DIR/$(basename -- "$src")"
done

prune_dangling

printf '\n'
if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Dry-Run: nichts verändert.\n'
else
    printf 'Fertig. Neue Shell starten, damit ~/.bashrc/.zshrc greifen.\n'
    if [ -d "$BACKUP_DIR" ]; then
        printf 'Gesicherte Originale: %s\n' "$BACKUP_DIR"
    fi
fi
[ -r "$HOME/.secrets" ] || printf 'Hinweis: ~/.secrets fehlt (API-Keys, chmod 600) – wird von .zshrc/.profile erwartet.\n'

[ "$ERRORS" -eq 0 ] || exit 1
