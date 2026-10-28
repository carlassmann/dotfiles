# ccssmnn - .dotfiles

## New machine

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

git clone https://github.com/carlassmann/dotfiles ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh --full
```

`--full` runs `brew bundle` against `Brewfile`, installs bun globals, Node and herdr, and applies `macos/defaults.sh` (keyboard, dock, finder). Without it, `install.sh` only creates symlinks.

Afterwards:

```bash
$EDITOR ~/.config/secrets/env   # export KEY="value" per line, sourced by zshenv
exec zsh
```

### Manual checklist

Sign in: 1Password, `gh auth login`, `claude`, `codex`, `opencode auth login`, Wispr Flow, browsers.

Grant in System Settings → Privacy & Security:

| app | permission |
| --- | --- |
| Karabiner-Elements | Input Monitoring, driver extension (Login Items & Extensions) |
| Rift | Accessibility (then `rift service restart`) |
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
| `rift/config.toml` | `~/.config/rift/config.toml` |
| `karabiner/` | `~/.config/karabiner` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml` |
| `macos/defaults.sh` | run by `install.sh --full`, not linked |
| `helix/` | `~/.config/helix` |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md` |
| `agents/skills/` | `~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills` |
| `agents/claude/settings.json` | `~/.claude/settings.json` |
| `agents/opencode/*` | `~/.config/opencode/*` |
| `scripts/bin/*` | `~/.local/bin/*` (on PATH: `pr-review`, `opencode-tunnel.ts`) |

## Workflow

- Ghostty is the terminal, herdr manages agent sessions.
- Helix is used as a file browser, not an IDE. `L d` / `L l` toggle dark / light theme.
- Karabiner maps Caps Lock to `Ctrl-Option-Cmd-Shift` (Hyper) for Rift, tap alone for Escape. Not Hyperkey: Rift reads keys before Hyperkey adds the modifiers.
- Agents write throwaway output to `.scratch/` in the repo they are working in. It is in
  `~/.gitignore_global`, so it stays inside the workspace without showing up as repo changes.
  `pr-review` and the counselors skill both use it.

### Remote opencode

`opencode-tunnel ensure` starts OpenCode's localhost background service,
creates a Cloudflare tunnel, protects it with an email allow-list in Access, and installs a
restart-on-crash macOS LaunchAgent. `status` checks the layers; `uninstall` removes only the
LaunchAgent. Node ≥ 24 runs the TypeScript directly.

Keep private values outside this repository. The script reads each setting from the
environment, or from a file of the same name in `~/.config/secrets`:

```sh
printf '%s\n' "..." > ~/.config/secrets/OPENCODE_TUNNEL_HOSTNAME
chmod 600 ~/.config/secrets/OPENCODE_TUNNEL_HOSTNAME
```

Prefer the files. Everything exported by `~/.config/secrets/env` lands in the environment of
every shell and subprocess you or an agent starts, and the tunnel settings are only ever read
by this script.

| setting | notes |
| --- | --- |
| `OPENCODE_TUNNEL_HOSTNAME` | public hostname |
| `OPENCODE_TUNNEL_ALLOWED_EMAILS` | comma-separated Access allow-list |
| `OPENCODE_SERVER_PASSWORD` | needed initially; optional after pinning |
| `CLOUDFLARE_API_TOKEN` | optional after Access exists |
| `OPENCODE_TUNNEL_NAME` / `_PORT` / `_SESSION` | optional; defaults `opencode` / `8788` / `24h` |

Run `cloudflared tunnel login` once first. `ensure` configures Access before DNS or tunnel
startup and stops the tunnel if Access verification fails. Generated credentials, tunnel
configuration, hostname, allow-list, token, and password remain outside the repository.

### Tailnet access

Without Cloudflare, Tailscale can serve the same OpenCode service to your devices:

```sh
tailscale serve --bg --https=8788 http://127.0.0.1:8788
# https://<machine>.<tailnet>.ts.net:8788, tailnet-only
```

Tailnet membership replaces Cloudflare Access; the pinned OpenCode password still applies.
Serve config persists across reboots. Port 443 (the no-port URL) is taken by a root
`portless proxy` on this machine, hence the explicit port. Remove with
`tailscale serve --https=8788 off`.

### Rift

- Focus: `Hyper-h/j/k/l`, workspace: `Hyper-1..9`, monitor: `Hyper-o`
- Move a window: `Hyper-m`, release, then `h/j/k/l`, a workspace number, `o` (next monitor) or `Tab` (whole workspace to next monitor)
- Resize: `Hyper-r`, then `h/j/k/l`, `Esc`/`Enter` to leave
- Split orientation: `Hyper-v`, stack (tab strip): `Hyper-t`, balance: `Hyper-e`, last workspace: `Hyper-Tab`
- Service: `Hyper-s`, then `h/j/k/l` join, `f` float, `r` unjoin, `` ` `` reload
- Cancel any mode: `Esc`
### Not in Homebrew

- herdr: installed by `install.sh --full` via `curl -fsSL https://herdr.dev/install.sh | sh`
- Node via `fnm` (`install.sh --full` runs `fnm install --lts`)
- `work`, `opencode`, `agent-browser` via bun globals
