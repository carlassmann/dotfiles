#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source:target pairs. Keep in sync with the layout table in README.md.
links=(
  "zsh/.zshrc:$HOME/.zshrc"
  "zsh/.zshenv:$HOME/.zshenv"

  "git/.gitconfig:$HOME/.gitconfig"
  "git/.gitignore_global:$HOME/.gitignore_global"

  "rift/config.toml:$HOME/.config/rift/config.toml"
  "karabiner:$HOME/.config/karabiner"
  "helix:$HOME/.config/helix"
  "ghostty/config:$HOME/.config/ghostty/config"
  "herdr/config.toml:$HOME/.config/herdr/config.toml"
  "lazygit/config.yml:$HOME/Library/Application Support/lazygit/config.yml"

  # Claude reads ~/.claude — link tracked config individually so runtime data
  # (projects, history, tasks) stays out of the repo
  "agents/claude/settings.json:$HOME/.claude/settings.json"
  "agents/AGENTS.md:$HOME/.claude/CLAUDE.md"
  "agents/skills:$HOME/.claude/skills"

  # Codex picks up AGENTS.md and skills/ from ~/.codex
  "agents/AGENTS.md:$HOME/.codex/AGENTS.md"
  "agents/skills:$HOME/.codex/skills"

  # Opencode reads ~/.config/opencode — link tracked files individually so opencode
  # can still write generated files (bun.lock, node_modules) into the same dir
  "agents/opencode/AGENTS.md:$HOME/.config/opencode/AGENTS.md"
  "agents/opencode/opencode.json:$HOME/.config/opencode/opencode.json"
  "agents/opencode/plugins/compaction-budget:$HOME/.config/opencode/plugins/compaction-budget"
  "agents/opencode/package.json:$HOME/.config/opencode/package.json"
  "agents/opencode/agent:$HOME/.config/opencode/agent"
  "agents/opencode/skills:$HOME/.config/opencode/skills"
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

link_scripts() {
  local script
  for script in "$DOTFILES_DIR"/scripts/bin/*; do
    [ -e "$script" ] || continue
    link "scripts/bin/$(basename "$script")" "$HOME/.local/bin/$(basename "$script")"
  done
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
    git+https://github.com/ccssmnn/work-cli.git \
    agent-browser \
    prettier \
    prettier-plugin-tailwindcss \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted \
    @tailwindcss/language-server
}

install_node() {
  command -v fnm >/dev/null 2>&1 || return 0
  fnm install --lts
  fnm default lts-latest || true
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

for entry in "${links[@]}"; do
  link "${entry%%:*}" "${entry#*:}"
done

link_scripts

ensure_secrets_file

if [ "${1:-}" = "--full" ]; then
  install_homebrew_bundle
  install_bun_globals
  install_node
  install_herdr
  install_rift_service
  bash "$DOTFILES_DIR/macos/defaults.sh"
fi

echo ""
echo "✅ done"
echo ""
echo "next:"
echo "  ./install.sh --full   brew bundle, bun globals, node, herdr, macOS defaults (new machine)"
echo "  secrets: ~/.config/secrets/env (exported), or one file per setting below it"
echo "  exec zsh"
