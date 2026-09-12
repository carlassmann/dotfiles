#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local source="$DOTFILES_DIR/$1"
  local target="$2"

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$source" ]; then
      echo "✓ $target"
      return 0
    fi
    rm "$target"
  elif [ -e "$target" ]; then
    echo "- skipped $target (exists, not a symlink)"
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "✓ $target"
}

install_homebrew_bundle() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "- homebrew missing, skipping Brewfile (install from https://brew.sh)"
    return 0
  fi
  brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade
}

install_bun_globals() {
  command -v bun >/dev/null 2>&1 || return 0
  bun add -g \
    @opencode/cli \
    @ccssmnn/work-cli \
    counselors \
    agent-browser \
    prettier \
    prettier-plugin-tailwindcss \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted \
    @tailwindcss/language-server
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

link zsh/.zshrc "$HOME/.zshrc"
link zsh/.zshenv "$HOME/.zshenv"

link git/.gitconfig "$HOME/.gitconfig"
link git/.gitignore_global "$HOME/.gitignore_global"

link aerospace/aerospace.toml "$HOME/.aerospace.toml"
link helix "$HOME/.config/helix"
link ghostty/config "$HOME/.config/ghostty/config"
link herdr/config.toml "$HOME/.config/herdr/config.toml"
link lazygit/config.yml "$HOME/Library/Application Support/lazygit/config.yml"

# Claude reads ~/.claude — link tracked config individually so runtime data
# (projects, history, tasks) stays out of the repo
link agents/claude/settings.json "$HOME/.claude/settings.json"
link agents/AGENTS.md "$HOME/.claude/CLAUDE.md"
link agents/skills "$HOME/.claude/skills"

# Codex picks up AGENTS.md and skills/ from ~/.codex
link agents/AGENTS.md "$HOME/.codex/AGENTS.md"
link agents/skills "$HOME/.codex/skills"

# Opencode reads ~/.config/opencode — link tracked files individually so opencode
# can still write generated files (bun.lock, node_modules) into the same dir
link agents/opencode/AGENTS.md "$HOME/.config/opencode/AGENTS.md"
link agents/opencode/opencode.json "$HOME/.config/opencode/opencode.json"
link agents/opencode/package.json "$HOME/.config/opencode/package.json"
link agents/opencode/agent "$HOME/.config/opencode/agent"
link agents/opencode/skills "$HOME/.config/opencode/skills"

link agents/counselors/config.json "$HOME/.config/counselors/config.json"

# Pi stores runtime data beside config — link tracked files individually
link agents/pi/keybindings.json "$HOME/.pi/agent/keybindings.json"
link agents/pi/extensions "$HOME/.pi/agent/extensions"

ensure_secrets_file

if [ "${1:-}" = "--full" ]; then
  install_homebrew_bundle
  install_bun_globals
  install_herdr
  bash "$DOTFILES_DIR/macos/defaults.sh"
fi

echo ""
echo "✅ done"
echo ""
echo "next:"
echo "  ./install.sh --full   brew bundle, bun globals, herdr, macOS defaults (new machine)"
echo "  fnm install --lts     node"
echo "  put secrets in ~/.config/secrets/env"
echo "  exec zsh"
