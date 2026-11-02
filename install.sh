#!/usr/bin/env bash
# Installs the Fallout theme + CRT shader into ~/.config/ghostty.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
mkdir -p "$DEST/themes" "$DEST/shaders"
cp "$SRC/themes/Fallout" "$DEST/themes/Fallout"
cp "$SRC/shaders/fallout.glsl" "$DEST/shaders/fallout.glsl"
echo "Installed to $DEST/themes/Fallout and $DEST/shaders/fallout.glsl"
echo "Now add the config lines from README.md and reload the config (Cmd+Shift+,)."
