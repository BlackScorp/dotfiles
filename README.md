# dotfiles

Persönliche Konfiguration für meine Void-Linux-Systeme. Dieses Repository ist
die einzige Quelle der Wahrheit: Was hier liegt, wird per Symlink ins Home
verlinkt; alles andere in `~/.config` gehört nicht dazu.

## Installation

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` verlinkt jede Dot-Datei im Wurzelverzeichnis nach `~`, jeden
Eintrag aus `.config/` nach `~/.config/<name>` und jede Datei aus `.local/`
nach `~/.local/<pfad>`. Echte Dateien und Verzeichnisse,
die dort schon liegen, werden vorher nach
`~/.dotfiles-backup-<zeitstempel>/` verschoben. Tote Symlinks, die noch in
dieses Repo zeigen, werden entfernt. Das Skript ist idempotent und kann jederzeit
erneut laufen (z. B. nach dem Hinzufügen einer neuen Config).

```bash
./install.sh --dry-run     # nur zeigen, was passieren würde
./install.sh --no-backup   # nichts sichern, vorhandene Ziele überspringen
```

Pakete installieren:

```bash
sudo xbps-install -Su foot mango noctalia noctalia-greeter fuzzel pcmanfm \
    mpv mpv-mpris nvim tmux jq btop
```

Nach dem Verlinken eine neue Shell starten. `~/.secrets` (chmod 600) wird von
`.zshrc` und `.profile` erwartet und enthält API-Keys; die Datei ist absichtlich
nicht Teil des Repos.

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `.bashrc`, `.bash_profile`, `.profile`, `.zshrc`, `.rc`, `.gitconfig` | Shell, Aliase, Funktionen |
| `.config/mango` | Fenstermanager (aktiv), inkl. `noctalia.conf` (von Noctalia generiert) |
| `.config/autostart.sh` | Start durch mango: pipewire, wireplumber, noctalia |
| `.config/foot`, `.config/tmux`, `.config/nvim` | Terminal, Multiplexer, Editor |
| `.config/mpv`, `.config/pcmanfm` | Player, Dateimanager |
| `.config/gtk-3.0`, `.config/gtk-4.0` | GTK-Einstellungen; `gtk.css`/`noctalia*.css` werden von Noctalia erzeugt und sind ignoriert |
| `.config/xdg-desktop-portal`, `-wlr` | Portale (Screenshot/Screencast) |
| `.config/xbps.d` | lokales Paket-Repository |
| `.config/service`, `.config/service-env` | turnstile-Dienste; Laufzeitdaten sind ignoriert |
| `.config/AGENTS.md` | globale Agent-Regeln (Crush, Claude Code, Codex) |
| `.config/goose` | Goose: aktiver Provider, Modelle, Extensions, eigener System-Prompt |
| `.config/keepassxc` | KeepassXC GUI- und Browser-Einstellungen (ohne KeeShare-Key) |
| `.local/state/noctalia/settings.toml` | Noctalia-Shell: Bar, Widgets, Farben, Wallpaper-Pfade, Plugins |

Noctalia 5 speichert seine Einstellungen nicht unter `~/.config/noctalia`,
sondern in `$XDG_STATE_HOME/noctalia/settings.toml`. Diese Datei ist die
Wahrheit für Bar-Layout, Widgets, Theme/Palette und Wallpaper-Pfade; sie wird als
einzelne Datei verlinkt, damit der übrige State (Plugin-Downloads,
Benachrichtigungsverlauf, Caches) nicht ins Repo wandert. Noctalia schreibt
Änderungen direkt in die verlinkte Datei, sie landen also sofort im Repo.

Aus `settings.toml` erzeugt Noctalia generierte Theme-Dateien: `.config/mango/noctalia.conf`,
`.config/gtk-3.0|4.0/gtk.css` + `noctalia*.css` und `qt5ct`/`qt6ct/colors/noctalia.conf`.
Sie sind per `.gitignore` ausgenommen, weil sie bei jedem Theme-Wechsel neu
geschrieben werden. `state.toml` im selben Verzeichnis enthält nur Laufzeitzustand
und wird nicht versioniert. Die in `settings.toml` aktivierten Community-Plugins
müssen auf einem neuen System in Noctalia nachinstalliert werden.

Nicht mehr enthalten und bewusst entfernt: `eww`, `sway`, `swww` (nicht mehr
installiert; mango + noctalia übernehmen Fensterverwaltung, Panel und
Hintergrund). Die alten Stände stehen weiterhin in der Git-Historie, z. B.
`git show <commit>:.config/eww/eww.yuck`.

Nicht im Repo, weil reine Anwendungs- oder Laufzeitdaten: `niri`, `umbriel`
(Standard-Template), `noctalia` (leer), `alacritty`, `btop`, `htop`, Browser-,
Electron- und IDE-Profile.

## Neovim als vi

Die LazyVim-Konfiguration liegt unter `.config/nvim` und wird von `install.sh`
verlinkt. `.rc` definiert `vi` als Alias für `nvim`, sofern Neovim installiert
ist. Beim ersten Start benötigt LazyVim gegebenenfalls Netzwerkzugriff für
Plugins.

Mit `vi .` oder `vi /pfad/zum/projekt` startet links der Dateibaum und rechts ein
leerer Editor, ohne Dashboard oder Dateivorschau. `vi datei` öffnet weiterhin
direkt die angegebene Datei.

- `j` / `k`: im Dateibaum navigieren.
- `Enter`: Ordner aufklappen oder Datei rechts öffnen.
- `Leertaste`, dann `e`: Dateibaum umschalten.
- `Strg+w`, dann `h` / `l`: zwischen Dateibaum und Editor wechseln.
- `:qa`: alle Fenster schließen und Neovim beenden.

Lua-Syntaxprüfung: `find .config/nvim -name '*.lua' -exec luajit -b {} /dev/null \;`.

## Secrets

Nichts Geheimes gehört ins Repo. Die einzelnen Stellen:

| Programm | Ablage | Warum nicht im Repo |
| --- | --- | --- |
| Shell | `~/.secrets` (chmod 600), gesourct von `.zshrc` und `.profile` | API-Keys wie `DEEPSEEK_API_KEY` |
| Goose | OS-Keyring, `~/.config/goose/secrets.yaml` | `config.yaml` enthält nur Provider, Modelle, Hosts; OAuth-Token liegen in `chatgpt_codex/`, `*_oauth/` und sind ignoriert |
| KeepassXC | `~/.config/keepassxc/keepassxc.ini` wird versioniert, aber **ohne** KeeShare-Block | KeepassXC kann keine Werte aus externen Dateien beziehen, der `Own`-PrivateKey muss also in der Datei stehen oder die Datei bleibt draußen |
| KeepassXC-Datenbank | `~/.passwords.kdbx` | Nicht im Repo, separat übertragen |

Zum KeeShare-Key: Er signiert geteilte Gruppen, ist kein Datenbank-Passwort.
Da in `keepassxc.ini` kein aktiver Share eingetragen ist (`Active` ist leer),
wurde `Own=""` gesetzt. Erzeugt KeepassXC den Key bei aktivierter Freigabe neu,
erscheint das als Änderung in `keepassxc.ini` – dann nicht committen, sondern
per `git checkout .config/keepassxc/keepassxc.ini` verwerfen oder die
Freigabe-Funktion bewusst nutzen.

## Globale Agent-Regeln

Die gemeinsamen Regeln für Agenten (Crush, Claude Code, Codex) liegen unter
`.config/AGENTS.md` und werden nach `~/.config/AGENTS.md` verlinkt. Crush liest
diesen Pfad über `options.global_context_paths` in allen Projekten. Die Regeln
halten den Kontext klein: erst mit `grep` suchen, `view` mit `limit` und
`offset` lesen und vollständige Dateien nur bei Bedarf laden.

## Lokale Void-Pakete

`update-packages` verwaltet die Pakete aus dem Array `packages` am Anfang des
Skripts. Eingetragen sind `noctalia`, `noctalia-greeter` und `crush`. Das Repository
wird unter `~/void-packages` erwartet, alternativ lässt sich `VOID_PACKAGES_DIR`
setzen. Fehlt der Klon, fragt das Skript nach und klont bei Zustimmung
`void-linux/void-packages` inklusive `xbps-src binary-bootstrap`.

Voraussetzungen: Bash, XBPS, `flock` und `xgensum` aus dem Paket `xtools`.
Falls `xgensum` fehlt, einmalig `sudo xbps-install xtools` ausführen.

```bash
./update-packages
```

`update` verwendet `./xbps-src update-check`, übernimmt die höchste erkannte
Version, setzt `revision=1` und aktualisiert mit `xgensum -i` die Prüfsummen,
auch für mehrere Quelldateien. Vorher werden lokale Änderungen im Klon per
`git stash` gesichert, `git pull origin main` ausgeführt und der Stash wieder
angewendet und gelöscht; bei Konflikten bricht das Skript mit einem Hinweis ab.
Danach werden die Pakete gebaut und mit
`./xbps-src remove-autodeps` die Build-Abhängigkeiten im Masterdir entfernt.
Build-Abhängigkeiten des Hostsystems und heruntergeladene Quellen bleiben
unangetastet. Die neuen Pakete stehen in `hostdir/binpkgs` bereit. Das Repository
ist bereits in der XBPS-Konfiguration hinterlegt; die Installation übernimmt
die vorhandene Paketverwaltung, nicht dieses Skript. Beim Paketupdate ersetzt
XBPS die installierte ältere Version automatisch.

Bei einem Prüfsummenfehler wird das ursprüngliche Template wiederhergestellt.
Bei einem Buildfehler bleiben die aktualisierten Templates zur Fehlerbehebung
erhalten; die Bereinigung der Build-Abhängigkeiten wird trotzdem versucht.
Es gibt keinen separaten Build-Befehl: `./update-packages` baut nur
Pakete mit einer neu erkannten Upstream-Version und überspringt aktuelle
Pakete. Nach einem fehlgeschlagenen Build kann das korrigierte Template direkt
mit `./xbps-src pkg <paket>` im Repository erneut gebaut werden.

Die Versionserkennung ist heuristisch. Keine Ausgabe von `update-check` ist
kein sicherer Nachweis, dass ein Paket aktuell ist. Paketspezifische Regeln
können in `srcpkgs/<paket>/update` hinterlegt werden. Neue Upstream-Versionen
können zusätzliche manuelle Template- oder Patch-Anpassungen benötigen.
Prüfsummen werden aus den Downloads neu berechnet, nicht unabhängig vom
Upstream authentifiziert.

Syntaxprüfung: `bash -n update-packages`. Ablauf und Fehlerpfade können mit
simulierten `xbps-src`- und `xgensum`-Befehlen isoliert getestet
werden, ohne das echte Paket-Repository oder das System zu verändern.
