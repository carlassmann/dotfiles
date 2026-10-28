#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
OMARCHY_THEME="$HOME/.local/state/omarchy/current/theme"

# source:target pairs. Keep in sync with the layout table in README.md.
links=(
  "zsh/.zshrc:$HOME/.zshrc"
  "zsh/.zshenv:$HOME/.zshenv"

  "git/.gitconfig:$HOME/.gitconfig"
  "git/.gitignore_global:$HOME/.gitignore_global"

  "helix:$HOME/.config/helix"
  "ghostty/shared.conf:$HOME/.config/ghostty/shared.conf"

  # Claude reads ~/.claude — link tracked config individually so runtime data
  # (projects, history, tasks) stays out of the repo. Skills: see link_skills.
  "agents/claude/settings.json:$HOME/.claude/settings.json"
  "agents/AGENTS.md:$HOME/.claude/CLAUDE.md"

  # Codex picks up AGENTS.md and skills/ from ~/.codex
  "agents/AGENTS.md:$HOME/.codex/AGENTS.md"

  # Opencode reads ~/.config/opencode — link tracked files individually so opencode
  # can still write generated files (bun.lock, node_modules) into the same dir
  "agents/opencode/AGENTS.md:$HOME/.config/opencode/AGENTS.md"
  "agents/opencode/opencode.json:$HOME/.config/opencode/opencode.json"
  "agents/opencode/plugins/compaction-budget:$HOME/.config/opencode/plugins/compaction-budget"
  "agents/opencode/package.json:$HOME/.config/opencode/package.json"
  "agents/opencode/skills:$HOME/.config/opencode/skills"
)

macos_links=(
  "rift/config.toml:$HOME/.config/rift/config.toml"
  "karabiner:$HOME/.config/karabiner"
  "ghostty/config:$HOME/.config/ghostty/config"
  "herdr/config.toml:$HOME/.config/herdr/config.toml"
  "lazygit/config.yml:$HOME/Library/Application Support/lazygit/config.yml"
)

# Omarchy owns its ghostty and herdr configs (see include_ghostty_shared)
linux_links=(
  "lazygit/config.yml:$HOME/.config/lazygit/config.yml"
)

link() {
  local source="$DOTFILES_DIR/$1"
  local target="$2"

  if [ -L "$target" ]; then
    local current
    current="$(readlink "$target")"
    if [ "$current" = "$source" ]; then
      echo "✓ $target"
      return 0
    fi
    echo "~ $target (relinked, was $current)"
    rm "$target"
  elif [ -e "$target" ]; then
    echo "- skipped $target (exists, not a symlink)"
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "✓ $target"
}

link_all() {
  local entry
  for entry in "$@"; do
    link "${entry%%:*}" "${entry#*:}"
  done
}

link_scripts() {
  local script
  for script in "$DOTFILES_DIR"/scripts/bin/*; do
    [ -e "$script" ] || continue
    link "scripts/bin/$(basename "$script")" "$HOME/.local/bin/$(basename "$script")"
  done
}

# Link each skill on its own so tool-installed skills (Omarchy's, synced ones)
# can live beside them
link_skills() {
  local target_dir="$1"

  # Earlier installs linked the whole directory
  if [ -L "$target_dir" ] && [ "$(readlink "$target_dir")" = "$DOTFILES_DIR/agents/skills" ]; then
    rm "$target_dir"
  fi

  for skill in "$DOTFILES_DIR"/agents/skills/*/; do
    skill="$(basename "$skill")"
    link "agents/skills/$skill" "$target_dir/$skill"
  done

  # Drop links to skills removed from the repo
  for entry in "$target_dir"/*; do
    if [ -L "$entry" ] && [ ! -e "$entry" ] && [[ "$(readlink "$entry")" == "$DOTFILES_DIR"/* ]]; then
      rm "$entry"
    fi
  done
}

# Helix loads theme "omarchy" (see helix/config.toml)
link_helix_theme() {
  local theme="$DOTFILES_DIR/helix/themes/omarchy.toml"
  mkdir -p "$(dirname "$theme")"

  if [ "$OS" = Darwin ]; then
    [ -L "$theme" ] && rm "$theme"
    printf 'inherits = "github_dark"\n' >"$theme"
  else
    ln -sfn "$OMARCHY_THEME/helix.toml" "$theme"
  fi
  echo "✓ $theme"
}

# Claude uses theme "custom:omarchy"; Omarchy writes it on Linux, macOS gets plain dark
ensure_claude_theme() {
  local theme="$HOME/.claude/themes/omarchy.json"
  [ "$OS" = Darwin ] || return 0
  [ -e "$theme" ] && return 0
  mkdir -p "$(dirname "$theme")"
  printf '{ "name": "Omarchy", "base": "dark", "overrides": {} }\n' >"$theme"
  echo "✓ $theme"
}

# Omarchy owns ~/.config/ghostty/config (theme, font, migrations edit it in place),
# so include the shared settings instead of replacing it
include_ghostty_shared() {
  local config="$HOME/.config/ghostty/config"
  local line='config-file = ?shared.conf'

  if [ ! -f "$config" ] || [ -L "$config" ]; then
    echo "- skipped ghostty include ($config missing or a symlink)"
    return 0
  fi
  if ! grep -qxF "$line" "$config"; then
    printf '\n# Shared settings from dotfiles\n%s\n' "$line" >>"$config"
  fi
  echo "✓ $config includes shared.conf"
}

install_arch_packages() {
  local packages=(
    zsh
    git-delta git-lfs
    helix marksman
    uv
    otf-geist-mono-nerd
  )
  local missing=()
  for pkg in "${packages[@]}"; do
    pacman -Qq "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    omarchy pkg add "${missing[@]}"
  fi

  # Arch ships Helix as `helix`; EDITOR and git expect `hx`
  mkdir -p "$HOME/.local/bin"
  ln -sfn /usr/bin/helix "$HOME/.local/bin/hx"

  git lfs install --skip-repo >/dev/null

  if [ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/zsh ]; then
    chsh -s /usr/bin/zsh
  fi
}

install_homebrew_bundle() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "- homebrew missing, skipping Brewfile (install from https://brew.sh)"
    return 0
  fi
  brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade
}

# Same runtimes on macOS and Linux, no root needed
install_mise_tools() {
  mise use -g node@lts bun@latest
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  # Matches zshenv; without it mise's bun puts globals in ~/.cache/.bun
  export BUN_INSTALL="$HOME/.bun"
}

install_bun_globals() {
  command -v bun >/dev/null 2>&1 || return 0
  bun add -g \
    @opencode/cli \
    git+https://github.com/ccssmnn/work-cli.git \
    portless \
    agent-browser \
    prettier \
    prettier-plugin-tailwindcss \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted \
    @tailwindcss/language-server
}

# work routes commands through portless' HTTPS proxy on :443; the service
# install elevates itself with sudo
install_portless_service() {
  command -v portless >/dev/null 2>&1 || return 0
  portless service status | grep -q "Installed: yes" && return 0
  portless service install
}

install_rift_service() {
  command -v rift >/dev/null 2>&1 || return 0
  rift service install
  rift service start
}

install_herdr() {
  command -v herdr >/dev/null 2>&1 && return 0
  curl -fsSL https://herdr.dev/install.sh | sh
}

ensure_secrets_file() {
  mkdir -p "$HOME/.config/secrets"
  touch "$HOME/.config/secrets/env"
  chmod 600 "$HOME/.config/secrets/env"
}

echo "🚀 linking dotfiles from $DOTFILES_DIR"

link_all "${links[@]}"
if [ "$OS" = Darwin ]; then
  link_all "${macos_links[@]}"
else
  link_all "${linux_links[@]}"
  include_ghostty_shared
fi

link_helix_theme
link_skills "$HOME/.claude/skills"
link_skills "$HOME/.codex/skills"
ensure_claude_theme
link_scripts

ensure_secrets_file

if [ "${1:-}" = "--full" ]; then
  if [ "$OS" = Darwin ]; then
    install_homebrew_bundle
  else
    install_arch_packages
  fi
  install_mise_tools
  install_bun_globals
  install_portless_service
  install_herdr
  if [ "$OS" = Darwin ]; then
    install_rift_service
    bash "$DOTFILES_DIR/macos/defaults.sh"
  fi
fi

echo ""
echo "✅ done"
echo ""
echo "next:"
echo "  ./install.sh --full   packages (brew / pacman), node + bun, bun globals, herdr, OS defaults (new machine)"
echo "  secrets: ~/.config/secrets/env (exported), or one file per setting below it"
echo "  exec zsh"
