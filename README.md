# ccssmnn - .dotfiles

## New machine

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

git clone https://github.com/carlassmann/dotfiles ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh --full
```

`--full` runs `brew bundle` against `Brewfile`, installs bun globals and herdr, and applies `macos/defaults.sh` (keyboard, dock, finder, Hyperkey prefs). Without it, `install.sh` only creates symlinks.

Afterwards:

```bash
fnm install --lts
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
| `ghostty/config` | `~/.config/ghostty/config` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml` |
| `macos/defaults.sh` | run by `install.sh --full`, not linked |
| `helix/` | `~/.config/helix` |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md` |
| `agents/skills/` | `~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills` |
| `agents/claude/settings.json` | `~/.claude/settings.json` |
| `agents/opencode/*` | `~/.config/opencode/*` |
| `agents/counselors/config.json` | `~/.config/counselors/config.json` |
| `agents/pi/keybindings.json` | `~/.pi/agent/keybindings.json` |
| `agents/pi/extensions/` | `~/.pi/agent/extensions` |
| `scripts/bin/` | on PATH (`pr-review`) |

## Workflow

- Ghostty is the terminal, herdr manages agent sessions.
- Helix is used as a file browser, not an IDE. `L d` / `L l` toggle dark / light theme.
- Hyperkey maps Caps Lock to `Ctrl-Option-Cmd-Shift` (Hyper) for AeroSpace.

### Remote opencode

`node scripts/bin/opencode-tunnel.ts ensure` starts OpenCode's localhost background service,
creates a Cloudflare tunnel, protects it with an email allow-list in Access, and installs a
restart-on-crash macOS LaunchAgent. `status` checks the layers; `uninstall` removes only the
LaunchAgent. Node ≥ 24 runs the TypeScript directly.

Keep private values in `~/.config/secrets/env`, never this repository:

```sh
export OPENCODE_TUNNEL_HOSTNAME="..."
export OPENCODE_TUNNEL_ALLOWED_EMAILS="...,..."
export OPENCODE_SERVER_PASSWORD="..." # needed initially; optional after pinning
export CLOUDFLARE_API_TOKEN="..." # optional after Access exists
```

Run `cloudflared tunnel login` once first. `ensure` configures Access before DNS or tunnel
startup and stops the tunnel if Access verification fails. Generated credentials, tunnel
configuration, hostname, allow-list, token, and password remain outside the repository.

### AeroSpace

- Focus: `Hyper-h/j/k/l`, workspace: `Hyper-1..9`, monitor: `Hyper-o`
- Move a window: `Hyper-m`, release, then `h/j/k/l`, a workspace number, `o` (next monitor) or `Tab` (whole workspace to next monitor)
- Resize: `Hyper-r`, then `h/j/k/l`, `Esc`/`Enter` to leave
- Cancel any mode: `Esc`

### Not in Homebrew

- herdr: installed by `install.sh --full` via `curl -fsSL https://herdr.dev/install.sh | sh`
- Node via `fnm`
- `work`, `opencode`, `counselors`, `agent-browser` via bun globals
