# Fallout theme for Ghostty / cmux

Green phosphor colour theme plus an optional CRT shader (curvature, scanlines, soft glow,
rolling bar, vignette) inspired by Pip-Boy terminals.

The shader is tuned for readability: the glow only spreads from brighter neighbours and the
green tint is partial, so highlighted blocks (e.g. diff backgrounds) stay sharp instead of
showing ghosted text.

## Contents

| File | What it is |
|---|---|
| `themes/Fallout` | Colour theme (background, foreground, cursor, palette 0–7) |
| `shaders/fallout.glsl` | CRT custom shader |
| `install.sh` | Copies both into `~/.config/ghostty` |

## Install

```bash
git clone https://github.com/chlp/ghostty-fallout-theme.git
cd ghostty-fallout-theme
./install.sh
```

Or manually:

```bash
mkdir -p ~/.config/ghostty/themes ~/.config/ghostty/shaders
cp themes/Fallout ~/.config/ghostty/themes/
cp shaders/fallout.glsl ~/.config/ghostty/shaders/
```

### Ghostty

Add to `~/.config/ghostty/config`:

```ini
theme = Fallout
custom-shader = ~/.config/ghostty/shaders/fallout.glsl
custom-shader-animation = true
cursor-style = block
cursor-style-blink = true
```

### cmux

Set the theme (cmux reads themes from `~/.config/ghostty/themes`):

```bash
cmux themes set --dark Fallout
```

Then add the shader lines to the cmux Ghostty config:

```bash
open -e "$HOME/Library/Application Support/com.cmuxterm.app/config.ghostty"
```

```ini
custom-shader = ~/.config/ghostty/shaders/fallout.glsl
custom-shader-animation = true
cursor-style = block
cursor-style-blink = true
```

Reload the config with `Cmd+Shift+,` or open a new tab.

The theme works without the shader — skip the `custom-shader*` lines for a flat look.

## Tuning the shader

Edit the `#define`s at the top of `shaders/fallout.glsl`:

| Parameter | Default | Effect |
|---|---|---|
| `TINT_AMOUNT` | 0.35 | 0 = original colours, 1 = full mono green (hurts contrast) |
| `BLOOM_STRENGTH` | 0.22 | Glow; set 0 if text looks soft |
| `BLOOM_SPREAD` | 1.5 | Glow radius in pixels |
| `SCANLINE_STRENGTH` | 0.18 | Scanline darkness |
| `NOISE_STRENGTH` | 0.025 | Film grain |
| `FLICKER_STRENGTH` | 0.015 | Brightness flicker |
| `CURVE` | 18.0, 14.0 | Screen curvature; higher = flatter |
| `VIGNETTE_STRENGTH` | 0.18 | Dark corners |
| `BAR_INTENSITY` | 0.06 | Rolling bright bar |

For a stronger retro look try `TINT_AMOUNT 0.5` and `SCANLINE_STRENGTH 0.25`.

Turn off `custom-shader-animation` to stop the flicker / rolling bar and save battery.

## Uninstall

Remove the `theme` / `custom-shader*` lines from the config, then:

```bash
rm ~/.config/ghostty/themes/Fallout ~/.config/ghostty/shaders/fallout.glsl
```
