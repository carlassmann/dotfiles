# ccssmnn - .dotfiles

## New machine

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

git clone https://github.com/carlassmann/dotfiles ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh --full
```

`--full` runs `brew bundle` against `Brewfile`, installs node and bun via mise, bun globals and herdr, and applies `macos/defaults.sh` (keyboard, dock, finder, Hyperkey prefs). Without it, `install.sh` only creates symlinks.

### Omarchy (Arch)

```bash
git clone https://github.com/carlassmann/dotfiles ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh --full
```

`--full` installs zsh, delta, git-lfs, helix, marksman, uv and Geist Mono via `omarchy pkg add`, links `hx` to `helix`, makes zsh the login shell, then node and bun via mise and bun globals. Omarchy already ships gh, mise, starship, zoxide, fzf, lazygit, lazydocker, ghostty and herdr.

Themes follow `omarchy theme set`: Ghostty, Helix (`omarchy` theme), Claude Code (`custom:omarchy`), opencode (`system`) and herdr (`terminal`) all retint. Omarchy owns `~/.config/ghostty/config` and `~/.config/herdr/config.toml`; install.sh only appends an include of `ghostty/shared.conf`. Font: `omarchy font set "GeistMono Nerd Font"`.

Afterwards (both):

```bash
$EDITOR ~/.config/secrets/env   # export KEY="value" per line, sourced by zshenv
exec zsh
```

### Manual checklist

Sign in: 1Password, `gh auth login`, `claude`, `codex`, `opencode auth login`, Wispr Flow, browsers.

Grant in System Settings → Privacy & Security:

| app | permission |
| --- | --- |
| Hyperkey | Accessibility, Input Monitoring |
| AeroSpace | Accessibility |
| Wispr Flow | Accessibility, Microphone |
| 1Password | Accessibility (autofill), browser extension |
| Ghostty | Full Disk Access (optional) |

Log out once so keyboard defaults take effect.

## Layout

| path | linked to |
| --- | --- |
| `zsh/.zshenv` | `~/.zshenv` (PATH, env, secrets) |
| `zsh/.zshrc` | `~/.zshrc` (interactive: prompt, completions, aliases) |
| `git/.gitconfig` | `~/.gitconfig` (includes `~/.gitconfig.local` for machine state) |
| `git/.gitignore_global` | `~/.gitignore_global` |
| `aerospace/aerospace.toml` | `~/.aerospace.toml` |
| `ghostty/config` | `~/.config/ghostty/config` (macOS only) |
| `ghostty/shared.conf` | `~/.config/ghostty/shared.conf`, included by either config |
| `herdr/config.toml` | `~/.config/herdr/config.toml` (macOS only) |
| `lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml`, `~/.config/lazygit/config.yml` on Linux |
| `macos/defaults.sh` | run by `install.sh --full`, not linked |
| `helix/` | `~/.config/helix`; `themes/omarchy.toml` is generated (Omarchy theme, or github_dark on macOS) |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md` |
| `agents/skills/*` | each skill into `~/.claude/skills/`, `~/.codex/skills/`; whole dir to `~/.config/opencode/skills` |
| `agents/claude/settings.json` | `~/.claude/settings.json` |
| `agents/opencode/*` | `~/.config/opencode/*` |
| `agents/pi/keybindings.json` | `~/.pi/agent/keybindings.json` |
| `agents/pi/extensions/` | `~/.pi/agent/extensions` |
| `scripts/bin/` | on PATH (`pr-review`) |

## Workflow

- Ghostty is the terminal, herdr manages agent sessions.
- Helix is used as a file browser, not an IDE. `L d` / `L l` toggle dark / light theme.
- Hyperkey maps Caps Lock to `Ctrl-Option-Cmd-Shift` (Hyper) for AeroSpace.

### AeroSpace

- Focus: `Hyper-h/j/k/l`, workspace: `Hyper-1..9`, monitor: `Hyper-o`
- Move a window: `Hyper-m`, release, then `h/j/k/l`, a workspace number, `o` (next monitor) or `Tab` (whole workspace to next monitor)
- Resize: `Hyper-r`, then `h/j/k/l`, `Esc`/`Enter` to leave
- Cancel any mode: `Esc`

### Not in Homebrew

- herdr: installed by `install.sh --full` via `curl -fsSL https://herdr.dev/install.sh | sh`
- Node and bun via `mise`
- `work`: cloned to `~/Developer/work-cli`, built and `bun link`ed (not on npm)
- `opencode`, `agent-browser` via bun globals
