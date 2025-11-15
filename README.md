# .dotfiles

Opinionated macOS workstation setup built around Helix, tmux, and Alacritty, plus a sprinkle of custom keyboard layouts. The repo is organized as self-contained modules so they can be stowed or linked individually.

## Stack overview
- Terminal: Alacritty launches `/bin/zsh -lc "tmux attach || tmux"`, pulls fonts from Liga SFMono Nerd Font, and imports the generated Zenburn palette.
- Multiplexer: `~/.tmux.conf` keeps pane management simple (`-` vertical, `|` horizontal, `hjkl` navigation, `HJKL` resize) and loads the generated Zenburn status theme alongside plugins like `aserowy/tmux.nvim` and the `ranger_tmux` dropper.
- Editor: Helix reads from `helix/config.d/*.toml`, giving relative line numbers, highlighted rulers, no mouse, and custom keybindings such as `Esc` formatting/saving the current buffer.
- Shell: Zsh + minimal Oh My Zsh configuration, custom aliases for `lsd`/`bat`, fzf-powered `fzf` and `project` helpers, extra toolchains sourced via `zsh/lib/40-extras.zsh`, and environment tweaks for Go/Solana.
- Input: ergonomic Ferris and Kinesis layouts live under `kbrd_layouts/` with layer screenshots in `screenshots/` to keep physical keyboards in sync with software layers.

## Repository layout
### `alacritty`
Contains the terminal config (`.config/alacritty/alacritty.toml`) that references generated palette files. Options cover live config reload, opacity, simple fullscreen, generous padding, scrollback, clipboard behavior, and shell startup command.

### `tmux`
Holds color themes produced by the shared palette pipeline (currently `themes/zenburn.tmux`) and is sourced from `~/.tmux.conf`. The main config lives in `$HOME` and is not tracked here, but the repo documents the key bindings and styling decisions referenced above.

### `helix`
`helix/config.d` stores small TOML fragments (theme, editor defaults, keymaps). `scripts/build_helix_config.sh` concatenates them into `helix/.config/helix/config.toml`, so edit the fragments instead of the generated file.

### `zsh`
`zsh/lib/*.zsh` files are sourced from `.zshrc` (not tracked). They configure the environment, aliases, helper functions, Oh My Zsh plugins, and optional extras like `fzf`, `opam`, `thunes`, or local env scripts.

### `scripts`
Utility helpers for keeping everything consistent:
- `build_theme.py` parses `themes/*.toml` and emits matching tmux, Helix, and Alacritty theme files.
- `build_helix_config.sh` concatenates Helix fragments into one config file.
- `refresh_configs.sh` stows (or manually symlinks) modules into `$HOME`; call it directly or set `DOTFILES_MODULES`/`TARGET_DIR` to limit scope.

### `themes`
Palette definitions (currently Zenburn) with shared ANSI colors and per-tool overrides. Run `python3 scripts/build_theme.py` after editing to regenerate all derived themes.

### `kbrd_layouts` & `screenshots`
Hardware layout JSON exports (Ferris compact split, Kinesis variants) plus layer screenshots referenced in documentation or for quick lookup when flashing firmware.

### `thunes` (optional)
Shell snippets for THUNES tooling sourced conditionally from `zsh/lib/40-extras.zsh`. Keep organization-specific secrets out of the repo; only helper scripts/config live here.

## Using these dotfiles
1. Clone the repo and `cd` into it.
2. Run `scripts/refresh_configs.sh` (with `stow` installed) to symlink modules into your home directory, or export `DOTFILES_MODULES="alacritty helix tmux zsh"` to link a subset.
3. Generate derived files when needed:
   - `python3 scripts/build_theme.py` to refresh Zenburn variants after palette tweaks.
   - `bash scripts/build_helix_config.sh` after changing files in `helix/config.d`.
4. Restart Alacritty/tmux/Helix (or use `tmux source-file ~/.tmux.conf`, `hx --health`, etc.) to pick up changes.

Keyboard layout images live under `screenshots/layer_*.PNG` for quick reference, and hardware JSONs can be flashed through their respective keyboard tooling.
