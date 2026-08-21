# ccssmnn - .dotfiles

## Quick Setup

```bash
# clone repo
git clone https://github.com/ccssmnn/dotfiles ~/Developer/dotfiles
cd ~/Developer/dotfiles

# run automated install
./install.sh
```

## Manual Setup

### Homebrew

Install [Homebrew](https://brew.sh)

```bash
brew install --cask ghostty hyperkey
brew install --cask nikitabobko/tap/aerospace

brew install \
  starship \
  gh \
  helix \
  lazygit \
  lazydocker \
  zoxide \
  fzf \
  tmux \
  git-delta \
  marksman \
  xplr \
  uv \
  deno 
```

### NodeJS & Bun

```bash
bun add -g \
  typescript \
  prettier \
  prettier-plugin-tailwindcss \
  prettier-plugin-astro \
  typescript-language-server \
  @prisma/language-server \
  @tailwindcss/language-server \
  @astrojs/language-server \
  vscode-langservers-extracted \
  opencode-ai
```

### Fonts

I'm using Geist Mono Nerd Font. [Download here](https://www.nerdfonts.com/font-downloads)

### Tmux workflow

- Ghostty shells auto-attach to tmux by default
- `tj` opens an fzf/zoxide-powered project picker and attaches/creates a session for that project
- `tj .` attaches/creates a session for the current git repo
- Inside tmux: `Ctrl-g c` opens a new window, `Ctrl-g s` opens the chooser, `Ctrl-g ,` / `Ctrl-g .` switches windows

### AeroSpace workflow

Hyperkey maps Caps Lock to `Ctrl-Option-Cmd-Shift`.

- Move a window: press `Hyper-m`, release, then press `h`, `j`, `k`, or `l`
- Move a window to workspace 1-9: press `Hyper-m`, release, then press the workspace number
- Move a window to the next monitor: press `Hyper-m`, release, then press `o`
- Move the workspace to the next monitor: press `Hyper-m`, release, then press `Tab`
- Cancel move mode: press `Esc`

### Secrets

`./install.sh` now prompts for required secrets declared in `agents/secrets.required` and stores them in:

- `~/.config/secrets/env` (chmod `600`)

Your `~/.zshrc` sources this file automatically.

## What Gets Symlinked

- `~/.zshrc` → `zsh/.zshrc`
- `~/.zshenv` → `zsh/.zshenv`
- `~/.gitconfig` → `git/.gitconfig`
- `~/.gitignore_global` → `git/.gitignore_global`
- `~/.aerospace.toml` → `aerospace/aerospace.toml`
- `~/.config/helix/` → `helix/`
- `~/.config/ghostty/config` → `ghostty/config`
- `~/.config/tmux/tmux.conf` → `tmux/.config/tmux/tmux.conf`
- `~/.config/tmux/themes` → `tmux/.config/tmux/themes`
- `~/.claude/settings.json` → `agents/claude/settings.json`
- `~/.claude/CLAUDE.md` → `agents/AGENTS.md`
- `~/.claude/skills` → `agents/skills`
- `~/.codex/AGENTS.md` → `agents/AGENTS.md`
- `~/.codex/skills` → `agents/skills`
- `~/.config/opencode/AGENTS.md` → `agents/opencode/AGENTS.md`
- `~/.config/opencode/opencode.json` → `agents/opencode/opencode.json`
- `~/.config/opencode/package.json` → `agents/opencode/package.json`
- `~/.config/opencode/agent` → `agents/opencode/agent`
- `~/.config/opencode/skills` → `agents/skills`
- `~/.config/counselors/config.json` → `agents/counselors/config.json`
