#!/usr/bin/env python3
"""Generate editor/terminal themes from a shared palette."""

from __future__ import annotations

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
THEMES_DIR = REPO_ROOT / "themes"


def resolve_color(value: str, palette: dict[str, str]) -> str:
    value = value.strip()
    if value.startswith("#"):
        return value.lower()
    try:
        return palette[value].lower()
    except KeyError as exc:  # pragma: no cover - configuration error helper
        raise SystemExit(f"Unknown color '{value}' in palette") from exc


def write_tmux_theme(theme: str, palette: dict[str, str], settings: dict[str, str], source: Path) -> None:
    required_keys = (
        "status_bg",
        "status_fg",
        "status_inactive_fg",
        "pane_border",
        "pane_active_border",
        "message_bg",
        "message_fg",
        "clock",
        "bell",
    )
    colors = {key: resolve_color(settings[key], palette) for key in required_keys}

    accent_color = palette.get("accent", colors["status_fg"])

    tmux_lines = [
        f"# Generated from {source.relative_to(REPO_ROOT)}; do not edit directly.",
        f"set -g status-bg \"{colors['status_bg']}\"",
        f"set -g status-fg \"{colors['status_fg']}\"",
        f"set -g message-style bg=\"{colors['message_bg']}\",fg=\"{colors['message_fg']}\"",
        f"set -g message-command-style bg=\"{colors['message_bg']}\",fg=\"{colors['message_fg']}\"",
        f"set -g pane-border-style fg=\"{colors['pane_border']}\"",
        f"set -g pane-active-border-style fg=\"{colors['pane_active_border']}\"",
        f"set -g clock-mode-colour \"{colors['clock']}\"",
        f"set -g display-panes-active-colour \"{colors['pane_active_border']}\"",
        f"set -g display-panes-colour \"{colors['pane_border']}\"",
        f"set -g status-left-length 40",
        f"set -g status-right-length 120",
        "set -g status-justify left",
        (
            "set -g window-status-style bg=\""
            f"{colors['status_bg']}"
            "\",fg=\""
            f"{colors['status_inactive_fg']}"
            "\"",
        ),
        (
            "set -g window-status-current-style bg=\""
            f"{colors['status_bg']}"
            "\",fg=\""
            f"{accent_color}"
            "\",bold",
        ),
        (
            "set -g status-left \"#[fg="
            f"{colors['pane_active_border']}",
            ",bold]#S #[fg=",
            f"{colors['status_inactive_fg']}",
            "]|\"",
        ),
        (
            "set -g status-right \"#[fg="
            f"{colors['status_inactive_fg']}",
            "]%Y-%m-%d #[fg=",
            f"{colors['pane_active_border']}",
            "]%H:%M #[fg=",
            f"{colors['status_inactive_fg']}",
            "]#H\"",
        ),
        f"set -g bell-action any",
        f"set -g visual-bell on",
    ]

    rendered = "\n".join(
        line if isinstance(line, str) else "".join(line) for line in tmux_lines
    )

    output = REPO_ROOT / "tmux" / "themes" / f"{theme}.tmux"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(rendered + "\n", encoding="utf-8")


def write_alacritty_theme(theme: str, palette: dict[str, str], ansi: dict[str, dict[str, str]], source: Path) -> None:
    normal = {name: resolve_color(value, palette) for name, value in ansi["normal"].items()}
    bright = {name: resolve_color(value, palette) for name, value in ansi["bright"].items()}

    lines = [
        f"# Generated from {source.relative_to(REPO_ROOT)}; do not edit directly.",
        "",
        "[colors.primary]",
        f"background = \"{palette['bg']}\"",
        f"foreground = \"{palette['fg']}\"",
        "",
        "[colors.cursor]",
        f"text = \"{palette['bg']}\"",
        f"cursor = \"{palette['cursor']}\"",
        "",
        "[colors.selection]",
        f"text = \"{palette['fg']}\"",
        f"background = \"{palette['selection']}\"",
        "",
        "[colors.normal]",
    ]

    for name in ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"):
        lines.append(f"{name} = \"{normal[name]}\"")

    lines.extend(["", "[colors.bright]"])
    for name in ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"):
        lines.append(f"{name} = \"{bright[name]}\"")

    output = REPO_ROOT / "alacritty" / ".config" / "alacritty" / "palettes" / f"{theme}.toml"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_helix_theme(theme: str, palette: dict[str, str], helix_cfg: dict[str, str], source: Path) -> None:
    inherits = helix_cfg.get("inherits")

    highlights = {
        "\"ui.background\"": "{ bg = \"bg\", fg = \"fg\" }",
        "\"ui.cursor\"": "{ bg = \"cursor\", fg = \"bg\" }",
        "\"ui.cursorline\"": "{ bg = \"bg_dim\" }",
        "\"ui.selection\"": "{ bg = \"selection\" }",
        "\"ui.menu.selected\"": "{ bg = \"accent\", fg = \"bg\" }",
        "\"ui.statusline\"": "{ fg = \"fg\", bg = \"bg_alt\" }",
        "\"ui.popup\"": "{ bg = \"bg_alt\" }",
        "\"ui.help\"": "{ fg = \"fg\", bg = \"bg_alt\" }",
        "\"ui.linenr\"": "\"fg_dim\"",
        "\"ui.linenr.selected\"": "\"fg\"",
        "\"ui.virtual.ruler\"": "{ bg = \"bg_alt\" }",
        "\"comment\"": "\"fg_dim\"",
        "\"keyword\"": "\"accent\"",
        "\"string\"": "\"green\"",
        "\"constant\"": "\"orange\"",
        "\"variable\"": "\"fg\"",
        "\"variable.builtin\"": "\"yellow\"",
        "\"function\"": "\"blue\"",
        "\"diagnostic.error\"": "\"red\"",
        "\"diagnostic.warning\"": "\"yellow\"",
        "\"diagnostic.info\"": "\"blue\"",
        "\"diagnostic.hint\"": "\"cyan\"",
    }

    palette_lines = "\n".join(
        f"{name} = \"{value}\"" for name, value in sorted(palette.items())
    )

    highlight_lines = "\n".join(f"{name} = {style}" for name, style in highlights.items())

    inherit_line = f"inherits = \"{inherits}\"\n\n" if inherits else ""

    content = (
        f"# Generated from {source.relative_to(REPO_ROOT)}; do not edit directly.\n"
        f"{inherit_line}"
        f"{highlight_lines}\n\n"
        f"[palette]\n{palette_lines}\n"
    )

    output = REPO_ROOT / "helix" / ".config" / "helix" / "themes" / f"{theme}.toml"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8")


def main() -> None:
    if not THEMES_DIR.exists():
        raise SystemExit("No themes directory found")

    for palette_file in sorted(THEMES_DIR.glob("*.toml")):
        data = parse_simple_toml(palette_file)
        palette = {key: value.lower() for key, value in data["palette"].items()}
        ansi = data["ansi"]
        tmux_settings = data["tmux"]
        theme_name = data["theme"]["name"]
        helix_cfg = data.get("helix", {})

        write_tmux_theme(theme_name, palette, tmux_settings, palette_file)
        write_alacritty_theme(theme_name, palette, ansi, palette_file)
        write_helix_theme(theme_name, palette, helix_cfg, palette_file)


def parse_simple_toml(path: Path) -> dict[str, dict[str, str]]:
    root: dict[str, dict[str, str]] = {}
    current_stack: list[str] = []
    current_table = root

    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line.startswith("[") and line.endswith("]"):
            current_stack = [segment.strip() for segment in line[1:-1].split(".")]
            current_table = root
            for segment in current_stack:
                current_table = current_table.setdefault(segment, {})
            continue
        if "=" not in line:
            continue
        key, value = [part.strip() for part in line.split("=", 1)]
        value = value.strip().strip('"')
        current_table[key] = value
    return root


if __name__ == "__main__":
    main()
