export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Developer/dotfiles/scripts/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export EDITOR="hx"

[ -f "$HOME/.config/secrets/env" ] && source "$HOME/.config/secrets/env"
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
