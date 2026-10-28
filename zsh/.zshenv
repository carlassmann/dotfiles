if [[ "$OSTYPE" == darwin* ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [ -r /usr/share/omarchy/default/bash/env-bootstrap ]; then
  # OMARCHY_PATH and mise shims; plain sh, safe to source from zsh
  source /usr/share/omarchy/default/bash/env-bootstrap
fi
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Developer/dotfiles/scripts/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export EDITOR="hx"

[ -f "$HOME/.config/secrets/env" ] && source "$HOME/.config/secrets/env"
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
